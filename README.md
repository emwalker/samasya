# Samasya

Samasya means "problem" in Hindi related languages.  It's being used here in the sense of a challenge problem of the kind you might work through to prepare for an exam.

This project exists to help me work through the domain model for a web app that would use spaced repetition to guide leaners through a series of challenge problems on the way to acquiring a new skill.  For example, the ability to analyze a complex physical system and then work out a partial derivative that can help to model it.  The web app should not assume too much about what the learner has already mastered.

## Questions and challenges

* How to avoid creating duplicate, redundant skills?  It looks like the skills are going to be somewhat specific.
* At what point should something be considered "mastered"?  What is it that is being  mastered?  A specific skill?  A cluster of skills?
* Is a cluster of skills simply an anonymous skill?
* What approach should be taken for concepts that are closely related, such that it would be hard to formulate a problem that didn't include two or more of them?  For example, the radius, circumference and diameter of a circle?  How to avoid skills that are too specific?
* What approach should be taken for concepts that are very basic, like measuring the length of a line, or working with circles and other geometric shapes?
* Will some problems be so specific that the prerequisite "skills" will simply be other, similar problems, with an additional dimension added?  How to model this?

## Goals and assumptions

Following are some goals and assumptions that should not be lost sight of:

* Problems will belong to a repo.  Authors can add problems to more than one repo.
* There may be more than one way to solve a problem using different approaches (think of a Leetcode problem).  We should not assume that there is a single way to solve a problem.  The existence of different approaches should be included in the domain model, and prerequisite skills should be relative to specific approaches.  It seems fine to hide this additional complexity from problem authors until a situation is encountered in which it's needed.

## Early problem statement

Following is a description I put together in October 2021 to try to illustrate the idea:

The purpose of the app would be to help people to rigorously acquire concrete problem solving skills and mastery of information that requires repetition and rote memorization to master.  The focus would be on problem solving skills and mastery of details that can be assessed by an app.  So matters pertaining to wisdom, style, taste, and other things that are hard to evaluate in an app would not be addressed, at least in the main track of content.

The app would largely be organized around concrete problems that the user is asked to try to solve.  In many cases, the problems would be word problems that state things in a concrete way without providing hints as to what is needed to solve them:

> A 1000 liter holding tank that catches runoff from some chemical process initially has 800 liters of water with 2 milliliters of pollution dissolved in it.  Polluted water flows into the tank at a rate of 3 liters/hr and contains 5 milliliters/liter of pollution in it.  A well mixed solution leaves the tank at 3 liters/hr as well.  When the amount of pollution in the holding tank reaches 500 milliliters the inflow of polluted water is cut off and fresh water will enter the tank at a decreased rate of 2 liters/hr while the outflow is increased to 4 liters/hr. Determine the amount of pollution in the tank at any time t.  (Adapted from [this page](https://tutorial.math.lamar.edu/classes/de/modeling.aspx).)

In this case, you need to construct a system of differential equations to solve the word problem, but the question text doesn't come out and say that.  The user would be required to infer that this is what is needed, and in a sense she is just thrown into the deep end of the pool.

Once the user is prompted with the problem text, she can attempt to solve the problem by choosing an answer from several possible answers.  Or she can opt out and say "I'm not sure."  In the case above, the problem will have been coded as one involving differential equations at a certain level of difficulty.  The app will know that being able to solve a problem involving differential calculus presupposes knowledge of arithmetic, algebra, integral calculus, and, in this case, units of measure.  Suppose the user chose "I'm not sure."  The app will then "bisect" through these prerequisite topics to find problems at a difficulty midway between easy and hard and then present these follow-on problems to her, GRE-style.  As she successfully or unsuccessfully answers these subsequent questions, the app will gradually get a sense of what kinds of problems in these topic areas she can readily solve and what kinds of problems she struggles with.  It will then put together a queue of problems in the prerequisite topics at a suitable level of difficulty to allow her to follow up on the areas she struggles with and eventually get to the point where she can tackle the initial problem without much difficulty, given enough time and repetition.

For those problems in prerequisite topics that she successfully solves, after the problem has been answered, she will be asked how easy or hard it was to solve it.  Her answer will be factored into how often she is shown a variation of the problem again in the future.  If she answers that it was easy to solve the problem, the rate at which she will be presented with a variation of the problem again will be low.  If she answers that it was challenging to solve the problem, she is likely to be shown some variation of the problem again in the near future.  There would be an exponentially increasing schedule on which she is shown a variation of a specific problem, depending on whether she successfully solves the problem and whether she found it easy or hard to do so.

In addition to differential equations, you can imagine other topic areas being covered as well:

* English vocabulary, spelling, punctuation, grammar and copyediting
* Algorithms and data structures
* Historical details relating to specific civilizations in central Asia
* Statistics and probability
* Biology
* Chemistry
* Public health
* Quantum mechanics
* Experimental design

In some cases, it might be possible to place a given problem within a single topic, but in other cases a problem might properly belong to several topic areas, e.g., biochemistry and public health.  The problems will often be word problems, and the coding scheme does not assume that a problem will necessarily fall within a single subtopic.

The questions and problems would be crowdsourced by volunteers under a Creative Commons license in the manner of Wikipedia.  There would be a main track of content that is organized, coded and curated by subject matter experts, many of them having built up a reputation within the system for the quality of their contributions.  There would also be other more experimental tracks of content that editors can curate and maintain outside of the main track.  A user of the system could have several queues of problems open at any given time that deal with different areas of interest.  For each group of problems within a specific topic and difficulty level, there might be a short narrative introduction and links to further reading.  The app would be intended to support and supplement a more formal educational process, in the manner of an after-school tutor, rather than replace a formal education altogether.

Eventually, you can imagine a skill tree being built up and filled out along the lines of those seen in computer games (e.g., Factorio), which would gamify things at a level to provide motivation to advance through the problem sets, but without going so far as to trivialize the learning process.  A careful balance would be struck here.

One motivation that more experienced users might have for adding content to the app would be to consolidate their own mastery of a new topic of interest.  As an editor learns more about the new topic, she might add problems to a queue of new problems that would be reviewed by other experienced editors and then coded for topic areas and given an initial guess as to level of difficulty, which would be adjusted later on as people attempt to answer the new question, and feedback and edits are incorporated.

As with Wikipedia, the software for the app would be available under a permissive license like the MIT license.  The UX of the app would feel modern and up to date, and the app would be hosted on a website.  Content in different languages and alphabets would be supported.
