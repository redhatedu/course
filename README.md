# course
All materials for course

#download all materials
git clone https://github.com/redhatedu/course.git


#Add materials to repo
mkdir shell
echo "test" > shell/test.txt
git add shell/test.txt
git commit -m 'add test file'
git push

#Remove materials from repo
git rm shell/test.txt
git commit -m 'remove test file'
git push
