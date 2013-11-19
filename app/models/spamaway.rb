class Spamaway < Tableless
  # This helper will generate pairs of human/robot statements and return
  # them alongside random strings.
  # There is no actual data in the database.

  @@human = [ 'I am a person.',
            'I have a heart.',
            'I eat food.',
            'I live on Earth.',
            'I am an organism',
            'I drink water' ]

  @@robot = [ 'I am a robot.',
            'I am a central processing unit.',
            'I am a computer.',
            'I am an algorithm.',
            'I live in a computer.',
            'I am here to write advertisements.' ]

  def get_pairs(how_many)
    # return how_many pairs of human/robot statements.
    if (how_many <= 0) or (how_many > @@human.size) or (how_many > @@robot.size)
      raise ArgumentError, "Cannot return " + how_many + " statements."
    end

    human_perms = @@human.permutation(how_many).to_a
    robot_perms = @@robot.permutation(how_many).to_a
    human_index = rand(human_perms.size)
    robot_index = rand(robot_perms.size)

    human_perms[human_index].zip(robot_perms[robot_index])
  end

end
