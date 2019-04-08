Salesforce cs check
===================

As we currently don't have any salesforce tools that allows for code
standard check and/or fixer. We created a bash script that checks for
simple rules in order to enforce basic CS.

The rules that we have for now includes:

- We are using `spaces` instead of `tabs`
- Tests should be names as `*Test.cls`
- That we have metadata files to all classes
- `@IsTest` usage is align with method declaration

You can easily add the check to you pipe line via `curl`, `wget` or even
by committing the script in your project.

*Note: your project should follow the structure of a `sfdx` project.*
