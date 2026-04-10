First, if the epic doesn't have failing tests, Always write failing tests BEFORE implementation
- Use AAA pattern: Arrange-Act-Assert
- One assertion per test when possible
- Test names describe behavior: "should_return_empty_when_no_items"

Tests should FAIL initially (no implementation exists). Only after tests are written, you can start working on the other tasks in the epic.

For each task, Only write enough code to pass the current tests, nothing more. Then, Refactor the implementation to improve code quality.
Tests must stay green after refactoring.

IMPORTANT: 
1/ Complete all the tasks in an epic without interruption, unless you need input from me
2/ If any tests produce fake or test data or artifacts, those data and artfiacts must be cleaned upon test completion
3/ at all times, you must use best software engineering practices. Follow these principles:

KISS (Keep It Simple, Stupid): Avoid over-engineering. Simple, readable code is easier to maintain and test.
DRY (Don't Repeat Yourself): Avoid code duplication by creating reusable modules, functions, or classes.
Separation of Concerns: Structure code into distinct sections, where each section addresses a specific concern.
Descriptive Naming: Use clear, consistent naming conventions for variables, functions, and classes.
Defensive Programming: Write code that anticipates potential failures, handles invalid inputs, and secures against vulnerabilities 
