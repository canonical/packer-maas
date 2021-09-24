# Copying packages to the custom image

Place your packages here and edit the _provisioners_ section in _ubuntu.json_ to copy them to the image. Notice that the operation is done by the user _ubuntu_, if you need to place a file in a restricted area, it can be done afterwards by the _curtin.sh_ script.
