final migraitons = [
  '''
  CREATE TABLE users(
    id INTEGER PRIMARY KEY, 
    token TEXT
  )''',

  '''
  CREATE TABLE sepet(
    id INTEGER PRIMARY KEY, 
    name TEXT, 
    price REAL, 
    adet INTEGER
  )''',
  '''
    ALTER TABLE users 
      ADD COLUMN apiUserId INTEGER
  ''',
  '''
    ALTER TABLE users 
      ADD COLUMN deneme TEXT
  ''',
];
