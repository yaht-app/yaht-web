class HabitForm
  include ActiveModel::Model

  attr_accessor :id, :goal_id, :is_template, :user_id, :user, :title, :description ,:duration, :schedule, :recurrence_on, :recurrence_at, :is_skippable, :is_enabled, :created_at, :updated_at

  validates :title, presence: true
  validates :duration, numericality: { only_integer: true }
  validates :recurrence_on, presence: true, array_inclusion: { in: %w[monday tuesday wednesday thursday friday saturday sunday] }
  validates :recurrence_at, presence: true
  validates :user_id, presence: true

  def initialize(params= {})
    if params[:id].present?
      @habit = Habit.find(params[:id])
      @config = @habit.current_config
      self.attributes=habit_params(params)
      self.attributes=config_params(params)
    else
      @habit = Habit.new(habit_params(params))
      @config = Habit::Config.new(config_params(params))
      super(params)
    end
  end

  # used to create a new habit
  def save(params = {})
    return false unless valid?

    ActiveRecord::Base.transaction do
      @habit.current_config = @config
      @config.habit = @habit
      @habit.save!
      raise ActiveRecord::Rollback unless errors.empty?
    end
    errors.empty?
  end

  # used to update an existing habit
  def update(params = {})
    return false unless valid?

    ActiveRecord::Base.transaction do
      @habit.update!(habit_params(params))
      new_config = @config.dup
      new_config.attributes = config_params(params)

      new_config.save!
      @config = new_config
      @habit.current_config = new_config
      @habit.save!
      raise ActiveRecord::Rollback unless errors.empty?
    end
    errors.empty?
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, 'Habit')
  end

  def persisted?
    @habit.nil? ? false : @habit.persisted?
  end

  def id
    @habit.nil? ? nil : @habit.id
  end

  def user_id
    if @user_id.nil?
      if @user.nil?
        nil
      else
        @user.id
      end
    else
      @user_id
    end
  end

  def config_params(params)
    params.slice(:duration, :schedule, :is_skippable, :is_enabled, :recurrence_on, :recurrence_at)
  end

  def habit_params(params)
    params.slice(:title, :description, :goal_id, :is_template, :user_id, :user, :id)
  end

  private
  # ...
end