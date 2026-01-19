# Otwell Polish

Apply the artisanal code refinement that Taylor Otwell brings to Laravel - the code that elevates good code to great code. This is the craft of leaving code better than you found it.

## Context Gathering

1. Determine what to polish:
   ```bash
   # Check for uncommitted changes first
   git diff --name-only
   git diff --name-only --cached
   ```

2. If changes exist, review those PHP files. If not, ask what to polish.

## Modes

### Review Mode (Default)

Invoked with `/otwell-polish` or `/otwell-polish <file/path>`

Analyze code and identify polish opportunities without making changes.

### Apply Mode

Invoked with `/otwell-polish apply` or `/otwell-polish apply <file/path>`

Analyze code AND apply all identified polish opportunities with explanations.

---

## The Otwell Philosophy

Taylor's style has evolved over 14 years. His philosophy:

- **"Simple and disposable and easy to change"** - Code should be easy to kill and rebuild
- **Against "cathedrals of complexity"** - Clever solutions are a code smell
- **"The clever dev always moves on"** - Write code your future self can understand
- **Work WITH the framework** - Departing from Laravel conventions is a warning sign
- **"Pretty average programmer"** - Solve problems simply, don't seek intellectual complexity
- **"Finish the backside of the dresser"** - Meticulous attention to detail, even where no one sees

---

## Polish Patterns (What TO Do)

### 1. The `tap()` Pattern - Avoid Temporary Variables

```php
// Before
$user = new User($attributes);
$user->save();
return $user;

// Polished
return tap(new User($attributes))->save();
```

```php
// Before
$user = User::create($data);
$user->notify(new WelcomeNotification);
return $user;

// Polished
return tap(User::create($data))->notify(new WelcomeNotification);
```

### 2. Defer Transformations to Output

Store raw data, transform on render. Prevents double-transformation bugs.

```php
// Before - escape on storage
$this->ignore = addslashes($id);

// Polished - escape on render
$this->ignore = $id;
// In __toString(): addslashes($this->ignore)
```

### 3. Strategic Line Breaks for Readability

Long method calls should breathe:

```php
// Before - cramped
$collection->add($this->{'addResource'.ucfirst($m)}($name, $base, $controller, $options));

// Polished - breathes
$collection->add($this->{'addResource'.ucfirst($m)}(
    $name, $base, $controller, $options
));
```

```php
// Before
$this->validate($request, ['name' => 'required|string|max:255', 'email' => 'required|email|unique:users', 'password' => 'required|min:8|confirmed']);

// Polished
$this->validate($request, [
    'name' => 'required|string|max:255',
    'email' => 'required|email|unique:users',
    'password' => 'required|min:8|confirmed',
]);
```

### 4. Collections Over Arrays

```php
// Before
$result = [];
foreach ($users as $user) {
    if ($user->active) {
        $result[] = $user->email;
    }
}

// Polished
$result = $users->filter->active->pluck('email');
```

### 5. Higher-Order Messages

```php
// Before
$users->filter(function ($user) {
    return $user->isAdmin();
});

// Polished
$users->filter->isAdmin();
```

```php
// Before
$users->map(function ($user) {
    return $user->email;
});

// Polished
$users->map->email;
```

### 6. Fluent Method Chains with `when()`

```php
// Before
$query = User::query();
if ($request->has('active')) {
    $query->where('active', true);
}
if ($request->has('role')) {
    $query->where('role', $request->role);
}
return $query->get();

// Polished
return User::query()
    ->when($request->has('active'), fn ($q) => $q->where('active', true))
    ->when($request->has('role'), fn ($q) => $q->where('role', $request->role))
    ->get();
```

### 7. `match` Over Nested Ternaries

```php
// Before
$status = $user->isAdmin() ? 'admin' : ($user->isModerator() ? 'mod' : 'user');

// Polished
$status = match (true) {
    $user->isAdmin() => 'admin',
    $user->isModerator() => 'mod',
    default => 'user',
};
```

### 8. Method Names That Read Like Prose

```php
// Before → Polished
$query->orderBy('created_at', 'desc');  →  $query->latest();
$query->orderBy('created_at', 'asc');   →  $query->oldest();
$request->input('name');                →  $request->string('name');
$collection->count() > 0;               →  $collection->isNotEmpty();
$collection->count() === 0;             →  $collection->isEmpty();
Carbon::now();                          →  now();
$user->created_at->format('Y-m-d');     →  $user->created_at->toDateString();
```

### 9. Guard Clauses (Early Returns)

```php
// Before
public function handle($request)
{
    if ($request->user()) {
        if ($request->user()->isAdmin()) {
            return $this->adminResponse();
        }
    }
    return $this->guestResponse();
}

// Polished
public function handle($request)
{
    if (! $request->user()) {
        return $this->guestResponse();
    }

    if (! $request->user()->isAdmin()) {
        return $this->guestResponse();
    }

    return $this->adminResponse();
}
```

### 10. Arrow Functions for Simple Closures

```php
// Before
$users->map(function ($user) {
    return $user->email;
});

// Polished
$users->map(fn ($user) => $user->email);
```

### 11. Helpers Over Facades

```php
// Before (Facades)
Str::slug($title);
Session::get('key');
Request::input('name');
Cache::get('key');

// Polished (Helpers)
str($title)->slug();
session('key');
request('name');
cache('key');
```

### 12. Modern PHP Features

```php
// Constructor promotion
public function __construct(
    public readonly string $name,
    public readonly string $email,
) {}

// Null coalescing assignment
$this->value ??= $this->computeDefault();

// Named arguments for clarity
User::create(
    name: $request->name,
    email: $request->email,
);
```

### 13. Laravel Shortcuts

```php
// Before - manual route definitions
Route::get('/users', [UserController::class, 'index']);
Route::get('/users/{user}', [UserController::class, 'show']);
Route::post('/users', [UserController::class, 'store']);
// etc...

// Polished
Route::resource('users', UserController::class);
```

### 14. Property/Method Organization

Logical grouping and ordering:
- Properties: constants → static → instance (related properties grouped)
- Methods: public API first, then protected, then private helpers
- Blank lines between logical sections

---

## Anti-Patterns (What NOT to Do)

Flag these as "unpolished" and suggest the polished alternative:

### 1. Nested Ternaries
```php
// Unpolished
$role = $user->admin ? 'admin' : ($user->mod ? 'mod' : 'user');
```

### 2. Temporary Variables for Simple Returns
```php
// Unpolished
$user = User::create($data);
return $user;
```

### 3. Verbose Collection Callbacks
```php
// Unpolished
$users->filter(function ($user) {
    return $user->active;
});
```

### 4. Manual foreach When Collection Method Exists
```php
// Unpolished
$emails = [];
foreach ($users as $user) {
    $emails[] = $user->email;
}
```

### 5. Cramped Multi-Parameter Calls
```php
// Unpolished
$this->validate($request, ['name' => 'required|string|max:255', 'email' => 'required|email|unique:users']);
```

### 6. Deeply Nested Conditionals
```php
// Unpolished
if ($user) {
    if ($user->active) {
        if ($user->verified) {
            return $this->allow();
        }
    }
}
```

### 7. Facades When Helpers Exist
```php
// Unpolished
Str::slug($title);
Session::get('key');
```

---

## Output Format

### Review Mode Output

```
## Otwell Polish Report

### Polish Opportunities

1. **file.php:42** - Use `tap()` to avoid temporary variable
   ```php
   // Current
   $user = User::create($data);
   $user->notify(new Welcome);
   return $user;

   // Polished
   return tap(User::create($data))->notify(new Welcome);
   ```

2. **file.php:78** - Use higher-order message
   ```php
   // Current
   $users->filter(function ($user) {
       return $user->active;
   });

   // Polished
   $users->filter->active;
   ```

### Already Polished
- Clean use of `when()` at line 23
- Good guard clause pattern at line 45
- Nice use of `tap()` at line 67

### Summary
Found 5 polish opportunities. The code is functional but could benefit from Taylor's finishing touches.
```

### Apply Mode Output

```
## Otwell Polish Applied

### Changes Made

1. **file.php:42** - Applied `tap()` pattern
   - Removed temporary variable, using higher-order tap

2. **file.php:78** - Converted to higher-order message
   - Simplified filter callback to `->filter->active`

3. **file.php:112** - Reformatted validation rules
   - Split long validation array across multiple lines

### Preserved
- Did not change business logic
- All functionality remains identical

### Summary
Applied 5 polish refinements. The code now has that Otwell touch.
```

---

## Remember

The goal is not to change WHAT the code does, only HOW it reads. Every change should make the code:
- More readable at a glance
- More idiomatic to Laravel
- More consistent with modern PHP
- More beautiful to look at

As Taylor says: "I want every little detail to be totally perfect because I don't feel confident building my own projects on it."
