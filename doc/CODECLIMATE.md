# Code Climate

We are implementing a [Code Climate](https://docs.codeclimate.com/docs) automation test to improve the quality of our code.

# Issues

CodeClimate is picky -- any time you think it's being too particular, you can ping @publiclab/reviewers and they can manually "approve" a PR and you can move forward -- not a problem! But if you click "details" next to CodeClimate, it'll offer some advice:

![Issues from a Pull Request](images/code_climate.png)

The most common is to refactor your code to avoid duplication or methods with
too many lines.

Below you can see CodeClimate complaining about "cognitive complexity" -- basically,
asking you to try to simplify how the code is written in order to make it more readable:

![Cognitive Complexity example](images/cognitive_complexity_example.png)

If you hover over the right-side of each issue, it has a "read more" link which offers some tips on how to resolve it:

![Cognitive Complexity example](images/codeclimate_read_up.png)

CodeClimate is picky so if you have more questions or need help, you can always
ask for help.
