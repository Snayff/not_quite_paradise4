# Git
## Branching
### Perform work in a feature branch
Because this way all work is done in isolation on a dedicated branch rather than the main branch. It allows you to submit multiple pull requests without confusion. You can iterate without polluting the master branch with potentially unstable, unfinished code.

We use the following branch prefixes, for branches outside of `develop` and `main`:
- `feature/`
- `docs/`
- `fix/`
### Branch out from `develop`
This way, you can make sure that code in master will almost always build without problems, and can be mostly used directly for releases (this might be overkill for some projects).
### Never push into `develop` or `master` branch. Make a Pull Request
 It notifies team members that they have completed a feature. It also enables easy peer-review of the code and dedicates forum for discussing the proposed feature.
### Resolve potential merge conflicts before submitting a Pull Request
### Delete local and remote feature branches after merging
It will clutter up your list of branches with dead branches. It ensures you only ever merge the branch back into (`master` or `develop`) once. Feature branches should only exist while the work is still in progress.
## Commits
## Past Tense
Commit messages should be in the past tense, e.g. `added support for mods`. The subject should be short and concise, with extra details noted in the body. 
## lower case
Both the subject and body of a commit should be in lower case. 
# Fix as You Go
We adopt a fix as you go attitude, meaning we generally avoid Pull Requests containing only style fixes. It is preferable to fix non-confirming code/content as we work on it. 
# Releases
## Semantic Versioning
Much like Godot, we use a loose version of Semantic Versioning, or [SemVer](https://semver.org/). 

# Working With the Project
## Know Your Colour
Hurtboxes use orange, specifically `f9870d6b`.
Physics, such as body collisions, use red, specifically `ff11006b`.
Target searching uses yellow, specifically `fef21e6b`.

## Node Icons
### Unique and Derived
We endeavour to create new node icons for all custom classes. Where there are a group of classes sharing the same custom-class parent we use unified a backdrop to the icon and a differentiating element in the bottom right corner, e.g. all VisualEffects have an eye as the background, then something unique in the foreground. 
### ABCs
If you see and ABC icon, you know you need to use a subclass, and not that class directly, as it is an Abstract Base Class.
# Attributions
Any media used must be added to the attribution list in the `_media_licenses` folder, along with its license. 