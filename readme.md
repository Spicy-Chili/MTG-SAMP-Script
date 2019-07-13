## Disclaimer

Welcome to the MTG SAMP development area. By accessing this area, you agree to the following:
 - You will never give the script or associated files to anybody who is not on the MTG SAMP development team
 - You will delete all development materials (script, databases, associated files, etc.) when you leave the MTG SAMP development team.
 
 
## Development Workflow 

While the current way we use Github works fine for projects where a few new features are added every once in awhile, the nature of SA:MP server development is we might add five different suggestions in one day. Creating a branch for each suggestion just ends up clogging up Github with 30 branches with one or two commits each. So I'm changing up the workflow to the following: 


### Small Scale Code Changes

Each developer should have three base branches named in the following convention:
Name-Suggestions
Name-BugFixes
Name-Mapping
Every suggestion, bug fix, mapping addition should be its own commit. That means we can revert any change quickly and easily by undoing the commit.

The commit title should be descriptive of what change has been made. For mapping, this should include the ID of the House, Biz, etc and the fact it is a House, Biz.

The commit description must include a link to the thread for the suggestion, bug, mapping request. This should allow us to track things easily.

When moving the thread to the appropriate section, add the commit hash in a reply. It'll need to be at least the first 7 characters but you can put the entire hash if it is easier. I know in GitKraken it defaults to copying the entire hash.

### Large Scale Code Changes

Large changes such as new systems, larger suggestions, etc should be in their own descriptively named branch.

For example:

Name-FriendsList
Name-DeathSystem
Name-UpdateVehicleStorage
Within this branch will be all the commits related to this. Once the code is finished a pull request (To TestServer-Master) should be opened that has the thread relating to the change being made.

The thread related to the change should then have a link to the pull request posted.

### Pull Requests

Unless otherwise stated, pull requests should always be to TestServer-Master first. All changes need to be tested on the TestServer before we pull to master.

### TestServer-Master

When testing things on the TestServer, fixes for code can be commited directly to TestServer-Master. This way we dont have to keep switching branches and opening pull requests for small changes.



