require 'valid_email'
require 'enumerize'

module AML
  class Operator < ApplicationRecord
    extend Enumerize
    include Workflow

    authenticates_with_sorcery! if defined? Sorcery

    enumerize :workflow_state, in: %w[blocked unblocked], scope: true
    enum role: [:operator, :administrator]

    scope :ordered, -> { order 'id desc' }

    has_many :orders, class_name: 'AML::Order', dependent: :destroy

    validates :password, length: { minimum: 8 }, on: :update, if: :crypted_password_changed?
    validates :password, confirmation: true, on: :update, if: :crypted_password_changed?
    validates :password_confirmation, presence: true, on: :update, if: :crypted_password_changed?
    validates :email, presence: true, uniqueness: true, email: true
    validates :name, presence: true, uniqueness: true

    after_commit :deliver_reset_password_instructions!, on: :create, if: :require_password_instruction?

    workflow do
      state :unblocked do
        event :block, transitions_to: :blocked
      end

      state :blocked do
        event :unblock, transitions_to: :unblocked
      end
    end

    def to_s
      "[#{id}] #{name}"
    end

    def to_partial_path
      'operator'
    end

    def require_password_instruction?
      defined?(Sorcery) && respond_to?(:deliver_reset_password_instructions!)
    end

    def active_for_authentication?
      unblocked?
    end

    # TODO move to sorcery
    #
    def change_password!(new_password)
      clear_reset_password_token
      self.password_confirmation = new_password
      self.password = new_password
      save!
    end
  end
end
