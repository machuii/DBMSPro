python3 manage.py migrate
echo "adding students...."
python3 add_students.py
echo "DONE"
echo "adding courses...."
python3 add_courses.py
echo "DONE"
echo "adding faculties...."
python3 add_faculties.py
echo "DONE"
echo "Database created successfully"
