# Mobile Database Assignment

The program made for this assignment is a simple note-taking application using Flutter and Isar as the database.

The application starts by defining a model called Task which is annotated with @Collection for Isar that contains id, title, and description. The openIsar() function starts Isar by locating the device application documents directory. In the main() function, Isar is opened and passed to the MyApp widget to set up the MaterialApp and display the TaskPage as the home page. This structure makes sure the database is ready before rendering the UI.

The TaskPage is a StatefulWidget that manages notes data. The state class _TaskPageState defines the notes list, text controller for search and for loading, adding, editing, and deleting notes using the transactional methods in Isar. The loadTasks() method retrieves notes from the database and filters using search query. Adding or editing notes is handled with prompts for users to input note details and saves changes to the database. Afterwards, each database operation calls loadTasks() to refresh the notes list.

The UI includes a search bar, notes lists in styled cards using ListView.builder, and buttons for editing and deleting notes. The floating action button triggers a prompt for adding a new note. The application calls setState() for state management whenever the notes list or search inquiry changes. This keeps the UI responsive and ensures the notes displayed are synchronized to the database.
