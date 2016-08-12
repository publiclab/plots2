class Spamaway < Tableless
  # This helper will generate pairs of human/robot statements and return
  # them alongside random strings.
  # There is no actual data in the database.

  column :follow_instructions, :string
  column :statement1, :string
  column :statement2, :string
  column :statement3, :string
  column :statement4, :string

  attr_accessible :follow_instructions,
                  :statement1,
                  :statement2,
                  :statement3,
                  :statement4

  validate :clean_honeypot, :human_responses

  def self.get_pairs(how_many)
    
    @human = [ I18n.t('spamaway.human.statement1'),
               I18n.t('spamaway.human.statement2'),
               I18n.t('spamaway.human.statement3'),
               I18n.t('spamaway.human.statement4'),
               I18n.t('spamaway.human.statement5'),
               I18n.t('spamaway.human.statement6') ]
            
    @robot = [ I18n.t('spamaway.robot.statement1'),
               I18n.t('spamaway.robot.statement2'),
               I18n.t('spamaway.robot.statement3'),
               I18n.t('spamaway.robot.statement4'),
               I18n.t('spamaway.robot.statement5'),
               I18n.t('spamaway.robot.statement6') ]
              
    # static method to return how_many pairs of human/robot statements.
    if (how_many <= 0) or (how_many > @human.length) or (how_many > @robot.length)
      raise ArgumentError, "Cannot return " + how_many + " statements."
    end

    # randomly select how_many statements from each list
    human_perms = @human.permutation(how_many).to_a
    robot_perms = @robot.permutation(how_many).to_a
    human_index = rand(human_perms.length)
    robot_index = rand(robot_perms.length)

    # slap pairs together
    pairs = human_perms[human_index].zip(robot_perms[robot_index])
    # randomly flip human/robot order for each statement pair
    pairs.each_index {
      |i| pairs[i] = pairs[i].permutation.to_a[rand()*2]
    }
    return pairs
  end

  def human_response?(response)
    @human = [ I18n.t('spamaway.human.statement1'),
               I18n.t('spamaway.human.statement2'),
               I18n.t('spamaway.human.statement3'),
               I18n.t('spamaway.human.statement4'),
               I18n.t('spamaway.human.statement5'),
               I18n.t('spamaway.human.statement6') ]
            
    @robot = [ I18n.t('spamaway.robot.statement1'),
               I18n.t('spamaway.robot.statement2'),
               I18n.t('spamaway.robot.statement3'),
               I18n.t('spamaway.robot.statement4'),
               I18n.t('spamaway.robot.statement5'),
               I18n.t('spamaway.robot.statement6') ]
    
    # return True if response is a human response, False otherwise.
    return @human.member? response
  end

  private

  def clean_honeypot
    # errors if the honeypot (follow_instructions) is not clean.
    if not (follow_instructions.blank? or follow_instructions == "")
      errors.add(:base, I18n.t('spamaway.errors.please_read_instructions'))
    end
  end

  def human_responses
    # confirms all statements are human responses.
    statements = [statement1, statement2, statement3, statement4]
    # turn statements into T/F array and keep only the Trues
    not_robot = statements.map { |a| human_response? a } .select { |a| a } 
    # make sure the number of Trues matches the number of original statements
    if (statements.length != not_robot.length)
      errors.add(:base, I18n.t('spamaway.errors.not_a_real_person'))
    end
  end

end
