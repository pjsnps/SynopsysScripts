#!/usr/bin/bash
#NAME: GitignoreTest.bash
#LICENSE: SPDX Apache-2.0
#AUTHOR: pjalajas@synopsys.com
#DATE: 2020-10-20
#VERSION:  2010201714Z

#Testing case 00820057 .gitignore https://jira-sig.internal.synopsys.com/browse/IDETECT-2186  
#Goal:  should see no "packages-split" in git status output? 
#WARNING: rm -rf ./.git and ./test 

echo cleaning up first...
echo WARNING: about to: rm -rf ./.git and ./test 
read -p "Ctrl+c to exit..."
rm -rf ./.git
rm -rf ./test
echo

echo making dirs...
mkdir -p ./test/c/customerssl/d/e/packages-split
mkdir -p ./test/c/customerssl/d/e/f 
mkdir -p ./test/a/customerssl/b/c 
mkdir -p ./test/a/customerssl/b/packages-split
mkdir -p ./test/f/g/customerssl/h/i/packages-split
mkdir -p ./test/f/g/customerssl/h/i/j 
echo

echo touching files...
touch ./test/c/customerssl/d/e/packages-split/cde.other
touch ./test/c/customerssl/d/e/f/cdef.other
touch ./test/pjtest.other
touch ./test/a/customerssl/b/c/abc.other
touch ./test/a/customerssl/b/packages-split/ab.other
touch ./test/f/g/customerssl/h/i/packages-split/fghi.other
touch ./test/f/g/customerssl/h/i/j/fghij.other
echo

#DOES NOT WORK ALONE: echo "customerssl/**/packages-split/" > ./test/.gitignore
#echo "customerssl/**/packages-split/" > ./test/.gitignore
#DOES NOT WORK ALONE ON FIRST RUN, BUT DOES ON SECOND??: echo "**/customerssl/**/packages-split/" >> ./test/.gitignore
echo "**/customerssl/**/packages-split/**" >> ./test/.gitignore

echo .gitignore:
grep -H '.*' ./test/.gitignore

echo 
echo git init...
git init .
#git init ./test/
#git rm -r --cached .
#git rm -r --cached ./test/
echo git status...
git status
echo 
echo git add...
git add ./test/
echo 
echo git status...
git status
echo 

echo removing ./test...
rm -rf ./test

#REFERENCE
: '
[pjalajas@sup-pjalajas-hub pjtest]$ bash GitignoreTest.bash 
cleaning up first...
WARNING: about to: rm -rf ./.git and ./test
Ctrl+c to exit...

making dirs...

touching files...

.gitignore:
./test/.gitignore:**/customerssl/**/packages-split/**

git init...
Initialized empty Git repository in /home/pjalajas/Documents/dev/hub/test/projects/cisco/pjtest/.git/
git status...
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       GitignoreTest.bash
#       test/
nothing added to commit but untracked files present (use "git add" to track)

git add...

git status...
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#       new file:   test/.gitignore
#       new file:   test/a/customerssl/b/c/abc.other
#       new file:   test/c/customerssl/d/e/f/cdef.other
#       new file:   test/f/g/customerssl/h/i/j/fghij.other
#       new file:   test/pjtest.other
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       GitignoreTest.bash

removing ./test...





[pjalajas@sup-pjalajas-hub pjtest]$ find . -path ./.git -prune -o -print                                                                                                                                                             
.
./c
./c/customerssl
./c/customerssl/d
./c/customerssl/d/e
./c/customerssl/d/e/packages-split
./c/customerssl/d/e/packages-split/cde.other
./c/customerssl/d/e/packages-split/cde.log
./c/customerssl/d/e/f
./c/customerssl/d/e/f/cdef.other
./pjtest.log
./a
./a/customerssl
./a/customerssl/b
./a/customerssl/b/c
./a/customerssl/b/c/abc.other
./a/customerssl/b/packages-split
./a/customerssl/b/packages-split/ab.other
./a/customerssl/b/packages-split/ab.log
./pjtest.lock
./pjtest.test
./f
./f/g
./f/g/customerssl
./f/g/customerssl/h
./f/g/customerssl/h/i
./f/g/customerssl/h/i/packages-split
./f/g/customerssl/h/i/packages-split/fghi.log
./f/g/customerssl/h/i/packages-split/fghi.other
./f/g/customerssl/h/i/j
./f/g/customerssl/h/i/j/fghij.other
./.gitignore
[pjalajas@sup-pjalajas-hub pjtest]$ 
[pjalajas@sup-pjalajas-hub pjtest]$ 
[pjalajas@sup-pjalajas-hub pjtest]$ 
[pjalajas@sup-pjalajas-hub pjtest]$ 
[pjalajas@sup-pjalajas-hub pjtest]$ 
[pjalajas@sup-pjalajas-hub pjtest]$ cat ./.gitignore 
#GOAL:  see no packages-split in git status?
customerssl/**/packages-split/
**/customerssl/**/packages-split/
customerssl/**/packages-split/**
**/customerssl/**/packages-split/**
[pjalajas@sup-pjalajas-hub pjtest]$ git status
# On branch master
#
# Initial commit
#
# Changes to be committed:
#   (use "git rm --cached <file>..." to unstage)
#
#       new file:   .gitignore
#       new file:   a/customerssl/b/c/abc.other
#       new file:   c/customerssl/d/e/f/cdef.other
#       new file:   f/g/customerssl/h/i/j/fghij.other
#       new file:   pjtest.lock
#       new file:   pjtest.log
#       new file:   pjtest.test
#
'
