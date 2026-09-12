Develop a comprehensive implementation plan, with features, tasks and release phases (including an MVP). Or, if one already exists in an implementation markdown file, start from that.

As you do this, imagine you were to break this project down into sprints and tasks. Every task/ticket should be atomic, committable piece of work with tests (and if tests don't make sense, another form of validation that it was completely successfully), every sprint shoudl result in a demoable piece of software that can be run, tested and built on top of previous work/sprints. Be exhaustive, be clear, be technical, always focus on small atomics tasks that compose up into a clear goal for the sprint. Then provide this prompt to a subagent to review your work work and suggest improvements. 


When you're done reviewing the suggested improvements, create tasks, epics, sprint plans, etc, ask me whether I want to set up beads tasks (https://github.com/steveyegge/beads) for task management or LInear (or both with Beads to LInear sync). 

Then create appropriate epics/projects & issues/tasks. Make sure that every epic/project has clear success critera, a suite of e2e tests, performance checks and security review.

Important Note #1: If beads epics & tasks already exist, review them, update them where needed, add/remove/merge epics where needed.
Important Note #2: if there is any UX aspects to this project, the first epic should always be a UX design epic, the goal of which is to output detailed mocks, a working HTML/CSS/JS prototype and a design system for this project.
Important Note #3: If there are any pre-build steps like infra setup, naming/branding/trademarks, validation steps, outreach, etc. Also create epics for these. They should be ordered first in the sequence, prior to dev.
