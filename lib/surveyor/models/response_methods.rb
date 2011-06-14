module Surveyor
  module Models
    module ResponseMethods
      def self.included(base)
        # Associations
        base.send :belongs_to, :response_set
        base.send :belongs_to, :question
        base.send :belongs_to, :answer
        @@validations_already_included ||= nil
        unless @@validations_already_included
          # Validations
          base.send :validates_presence_of, :response_set_id, :question_id, :answer_id

          @@validations_already_included = true
        end
        base.send :include, Surveyor::ActsAsResponse # includes "as" instance method

        # survey_section_id
        base.send :before_save, Proc.new{ |r| r.survey_section_id = r.question.survey_section_id if( r.question ) }

        # Class methods
        base.instance_eval do
          def applicable_attributes(attrs)
            result = HashWithIndifferentAccess.new(attrs)
            result[:answer_id] = result[:answer_id].
              compact.delete_if(&:blank?) if result[:answer_id].is_a?(Array)

            if (result[:answer_id].present? && result[:string_value] &&
                Answer.exists?(result[:answer_id]))
              answer = Answer.find(result[:answer_id])
              unless answer.is_a?(Array)
                result.delete(:string_value) unless (answer.response_class &&
                                                     answer.response_class.to_sym == :string)
              end
            end
            result
          end
        end
      end

      # Instance Methods
      def answer_id=(val)
        write_attribute :answer_id, (val.is_a?(Array) ? val.detect{|x| !x.to_s.blank?} : val)
      end
      def correct?
        question.correct_answer_id.nil? or self.answer.response_class != "answer" or (question.correct_answer_id.to_i == answer_id.to_i)
      end

      def to_s # used in dependency_explanation_helper
        if self.answer.response_class == "answer" and self.answer_id
          return self.answer.text
        else
          return "#{(self.string_value || self.text_value || self.integer_value || self.float_value || nil).to_s}"
        end
      end
    end
  end
end
