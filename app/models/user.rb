class User < ApplicationRecord

  has_many :habits, dependent: :destroy
  has_many :goals, dependent: :destroy
  has_many :occurrences, through: :habits
  has_many :reflections, dependent: :destroy
  has_many :habit_reflections, through: :reflections
  has_many :experience_sample_configs, dependent: :destroy
  has_many :samplings, through: :experience_sample_configs

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist

  validates :username, uniqueness: { case_sensitive: false }, presence: true, allow_blank: false, format: { with: /\A[a-zA-Z0-9\ } }._]+\z/ }
  validates :email,
            uniqueness: { case_sensitive: false },
            length: { minimum: 4, maximum: 254 }
  validates_format_of :email,:with => Devise::email_regexp
  validates :study_agreement, acceptance: { message: "must be checked"}, :allow_nil => false, :on => :create

  attr_writer :login

  enum role: [:subscriber,:researcher,:admin]

  serialize :reflection_on, Array
  serialize :reflection_at, Array

  def reflection_on
    read_attribute(:reflection_on) || ["friday"]
  end

  # used by devise to allow login via username or email
  def login
    @login || self.username || self.email
  end

  # required so devise can find the user based on the username and the email
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    elsif conditions.has_key?(:username) || conditions.has_key?(:email)
      where(conditions.to_h).first
    end
  end

  def reflection_at_string=(value)
    if value.is_a?(String)
      self.reflection_at=transform_string_to_times(value)
    else
      self.reflection_at=value
    end
  end

  def reflection_at_string
    if self.reflection_at.present?
      self.reflection_at.join(", ")
    else
      "17:00"
    end
  end

  # transforms a string of times to an array
  # e.g. "12:00, 09:00" will be turned into ["12:00","09:00"]
  def transform_string_to_times(string)
    string.scan(/([0-9]+:[0-9]+|[0-9]+\.[0-9]+|[0-9]{4})/i).flatten
  end

end
