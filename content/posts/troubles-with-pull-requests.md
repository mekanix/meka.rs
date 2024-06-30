+++
title = 'Troubles with pull requests'
date = 2015-02-27T22:00:00
tags = ['git', 'github']
+++


Imagine two repos with a pull request from one to another. What you're actually
doing when accepting pull request is equivalent of `git merge`, so your `HEAD`
will point to the merge commit upon accepting the pull request.  Nothing new
there, right? But what if you have hundreds of commits and you find a bug?
Well, that sure thought you to merge more often, for start. If not, leave the
Internet!

One thing I don't like about merges is that `git log` is funky. We as humans can
not think in jumps, which is the way computers and git commit parent work. We're
stranded in `git log`, and that's all that our brain can really comprehend. We
have to draw the tree and curves representing merges and whatnot. Now just
imagine you have thousands of commits. To be honest, yeah, there is information
which commit is merge and which is "normal", you can filter them out or show
only merges and filter by different criteria, but what we all really want is
"tell me what's wrong" button/command. Listing all those thousands of commits
one after the other really doesn't tell you much.

But what if you rebase, or cherry-pick one commit at a time? Then the first
commit that breaks the code will be spotted right away. Yes, it's more painful
because some conflicts you're having with rebase don't show up when doing merge.
The reason to do it is that you really don't want to think in jumps, which merge
commits really are. Imagine continuous stream of commits (read: `git log`) which
you don't have to imagine in your head as trees and branches. No double parent
commits, only pure code, one commit after another. It would be much easier to
read, but to be honest, I have no idea how would someone implement it. As it is,
merge commits (which pull requests really are) are the least evil we have.
