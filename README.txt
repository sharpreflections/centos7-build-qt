This dockerfile applies a bunch of patches on the Qt sourcecode.

One way to generate the patch files:
- checkout Qt5 source code from GitHub
- do the changes in the sourcefiles
- run git diff > 00x_my_patch_file_with_qt_module.patch to get a file with the patch included. 
  (Make sure the paths are correct, I had some trouble with the git submodules.
   I had to generate if from within the submodule and then manually prepend the qt module name to the patch path)
