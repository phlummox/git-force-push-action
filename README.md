# git-force-push-action

Does force-pushes from the repo where the action is 'installed', to some branch
in a remote repo - possibly on GitHub, possibly elsewhere, as long as it can be
written to using an ssh public/private key pair.

The target brannch needn't have the same name as the source (indeed it probably
shouldn't, if both are on GitHub and have actions enabled.)

## example workflow

**Step 1**

Create (or ensure you already have) a passwordless ssh public/private key pair
for the destination repo.

```
$ ssh-keygen -f some_name
# then hit return
# produces `some_name` and `somename.pub`.
```

**Step 2**

In the destination repo, add the contents of `somename.pub` as an ssh key with read/write access.
GitHub calls this a "deploy key"; make sure "write access" is checked.

We can use any destination repo, as long as we can express it as a  URL that `git` understands,
and that destination can use ssh public keys to perform repository writes.

**Step 3**

In the source repo, add the contents of `somename` as what GitHub calls a
"secret". These are typically named something like `MY_SECRET`.

**Step 4**

Add a workflow to a file in your repo (on the source branch that you're pushing) called e.g. `mypush.yml` (any name ending in `.yml`
should do), in a directory called `.github/workflows` with contents that we
shall see shortly...

So e.g.

```
$ git checkout -b my-workflow-control-branch
$ mkdir -p .github/workflows
$ touch .github/workflows/mypush.yml
```

... then add the following contents to `.github/workflows/mypush.yml`:

```
# contents of .github/workflows/mypush.yml

name: Force-push to remote branch

# we want to trigger for most all events happening on the
# source branch - let's assume it's "master":
on:
  push:
    branches:
      - 'master'
  create:
    branches:
      - 'master'
  delete:
    branches:
      - 'master'
# that hopefully should match pushing, and tag creation
# or deletion

# and we'll push TO some other-named branch in the
# remote repo. (Well - it could be the same name, but then if thar is
# on GitHub and has actions enabled, you'll
# get peculiar errors as that branch tries to force-push to itself,
# I imagine.) So the .github/workflows/mypush.yml file will
# have no effect in that branch.

jobs:
  force-push-my-master-branch:
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v1                  # must check out code, first
      - uses: phlummox/git-force-push-action@v0.1  # specify THIS action
        with:

          # specify source branch in this repo,
          # and destination repository & branch

          source_branch: master
          target_repo_url: 'git@github.com:someuser/somerepo.git'
          target_branch: some-remote-branch

          # specify whatever name you gave your private key

          ssh_private_key: ${{ secrets.MY_PRIVATE_KEY }}
```

... commit and push those changes:

```
$ git add .github/workflows/force-push.yml
$ git commit -m 'added force-push workflow'
$ git push --set-upstream origin my-workflow-control-branch
```

... and we're done.

Then GitHub will run a little Alpine docker container that
checks out your repo, and does (after setting up ssh keys):

```
$ git checkout master
$ git push --force --tags git@github.com:someuser/somerepo.git some-remote-branch
```

So all commits and tags from the source branch are force-pushed to the target
repo, and the branch they're on is labelled `some-remote-branch`.

Hopefully.

Use at your own risk; if it borks the destination repo, don't blame me.

See the file `entrypoint.sh` in this repo to see exactly what it does.


