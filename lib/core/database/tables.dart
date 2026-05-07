class Tables {
  Tables._();

  static const String categories = '''
    CREATE TABLE categories (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      icon TEXT NOT NULL,
      color TEXT NOT NULL,
      parent_id INTEGER,
      type TEXT NOT NULL,
      sort_order INTEGER,
      created_at TEXT NOT NULL,
      FOREIGN KEY (parent_id) REFERENCES categories(id)
    )
  ''';

  static const String accounts = '''
    CREATE TABLE accounts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      type TEXT NOT NULL,
      balance REAL NOT NULL,
      icon TEXT,
      color TEXT,
      currency TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL
    )
  ''';

  static const String expenses = '''
    CREATE TABLE expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id INTEGER,
      account_id INTEGER NOT NULL,
      to_account_id INTEGER,
      payee_id INTEGER,
      note TEXT,
      date TEXT NOT NULL,
      recurring_id INTEGER,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (account_id) REFERENCES accounts(id),
      FOREIGN KEY (to_account_id) REFERENCES accounts(id),
      FOREIGN KEY (payee_id) REFERENCES payees(id),
      FOREIGN KEY (recurring_id) REFERENCES recurring_transactions(id)
    )
  ''';

  static const String budgets = '''
    CREATE TABLE budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_id INTEGER,
      amount REAL NOT NULL,
      period TEXT NOT NULL,
      start_date TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    )
  ''';

  static const String recurringTransactions = '''
    CREATE TABLE recurring_transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      category_id INTEGER,
      account_id INTEGER NOT NULL,
      payee_id INTEGER,
      note TEXT,
      frequency TEXT NOT NULL,
      next_date TEXT NOT NULL,
      end_date TEXT,
      is_active INTEGER NOT NULL DEFAULT 1,
      created_at TEXT NOT NULL,
      FOREIGN KEY (category_id) REFERENCES categories(id),
      FOREIGN KEY (account_id) REFERENCES accounts(id),
      FOREIGN KEY (payee_id) REFERENCES payees(id)
    )
  ''';

  static const String tags = '''
    CREATE TABLE tags (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      color TEXT
    )
  ''';

  static const String expenseTags = '''
    CREATE TABLE expense_tags (
      expense_id INTEGER NOT NULL,
      tag_id INTEGER NOT NULL,
      PRIMARY KEY (expense_id, tag_id),
      FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
    )
  ''';

  static const String payees = '''
    CREATE TABLE payees (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      default_category_id INTEGER,
      FOREIGN KEY (default_category_id) REFERENCES categories(id)
    )
  ''';

  static const String splits = '''
    CREATE TABLE splits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      expense_id INTEGER NOT NULL,
      category_id INTEGER NOT NULL,
      amount REAL NOT NULL,
      note TEXT,
      FOREIGN KEY (expense_id) REFERENCES expenses(id) ON DELETE CASCADE,
      FOREIGN KEY (category_id) REFERENCES categories(id)
    )
  ''';

  static const String settings = '''
    CREATE TABLE settings (
      key TEXT PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''';

  static const List<String> allTables = [
    categories,
    accounts,
    payees,
    tags,
    expenses,
    expenseTags,
    splits,
    budgets,
    recurringTransactions,
    settings,
  ];
}
