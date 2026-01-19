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

### 15. Small, Focused Methods (Single Responsibility)

Methods should do ONE thing. If a method is longer than ~20 lines, it's probably doing too much.

```php
// Before - method doing too much
private function processExport(): ?string
{
    // validate input
    // fetch records
    // transform data
    // generate file
    // upload to storage
    // send notification
    // cleanup
    // ... way too much
}

// Polished - small focused methods
private function processExport(): ?string
{
    $records = $this->fetchRecords();

    if ($records->isEmpty()) {
        return null;
    }

    return $this->generateAndUpload($records);
}
```

### 16. Eager Load to Avoid N+1 Queries

Never query inside a loop. Load relationships upfront.

```php
// Before - N+1 query (bad!)
foreach ($orderItems as $item) {
    $product = Product::find($item->product_id);  // Query in loop!
}

// Polished - eager load
$orderItems = OrderItem::with('product')->where('order_id', $orderId)->get();

foreach ($orderItems as $item) {
    $productName = $item->product->name;
}

// Or - pre-load with pluck
$products = Product::whereIn('id', $orderItems->pluck('product_id'))
    ->pluck('name', 'id');

foreach ($orderItems as $item) {
    $productName = $products[$item->product_id] ?? 'Unknown';
}
```

### 17. Use Carbon, Not date()/strtotime()

Laravel casts dates to Carbon. Use it.

```php
// Before
date('Y-m-d', strtotime($user->created_at))

// Polished
$user->created_at->toDateString()

// Before
date('Y-m-d-His')

// Polished
now()->format('Y-m-d-His')
```

### 18. Extract Complex Logic to Helpers

When logic is complex, extract it. Name it well.

```php
// Before - inline complexity
$slug = str($title)->slug();
$originalSlug = $slug;
$counter = 1;

while (Post::where('slug', $slug)->exists()) {
    $slug = "{$originalSlug}-{$counter}";
    $counter++;
}

// Polished - extracted helper
$slug = $this->uniqueSlug($title);

// Helper method:
private function uniqueSlug(string $title): string
{
    $slug = str($title)->slug();

    if (! Post::where('slug', $slug)->exists()) {
        return $slug;
    }

    $counter = 1;

    do {
        $uniqueSlug = "{$slug}-{$counter}";
        $counter++;
    } while (Post::where('slug', $uniqueSlug)->exists());

    return $uniqueSlug;
}
```

### 19. Avoid Error Suppression (@)

The `@` operator hides problems. Handle errors explicitly.

```php
// Before
@unlink($tempFile);

// Polished
if (file_exists($tempFile)) {
    unlink($tempFile);
}

// Or use rescue() for "I don't care if it fails"
rescue(fn () => unlink($tempFile));
```

### 20. Collection Pipelines Over foreach with Side Effects

```php
// Before
foreach ($files as $file) {
    $content = Storage::get($file->path);
    if ($content === null) {
        continue;
    }
    $this->processFile($file, $content);
}

// Polished - filter first, then process
$files
    ->map(fn ($file) => ['file' => $file, 'content' => Storage::get($file->path)])
    ->filter(fn ($item) => $item['content'] !== null)
    ->each(fn ($item) => $this->processFile($item['file'], $item['content']));
```

### 21. Fluent Deletion Patterns

```php
// Before
Export::where('user_id', $userId)
    ->where('id', '!=', $latestId)
    ->each(function (Export $export) {
        if ($export->file_path) {
            Storage::delete($export->file_path);
        }
        $export->delete();
    });

// Polished - separate concerns
$oldExports = Export::where('user_id', $userId)
    ->where('id', '!=', $latestId)
    ->get();

Storage::delete($oldExports->pluck('file_path')->filter()->all());

$oldExports->each->delete();
```

### 22. Simplify with `value()` and `sole()`

```php
// Before
$latestId = Export::where('user_id', $userId)->latest()->first()->id;

// Polished
$latestId = Export::where('user_id', $userId)->latest()->value('id');

// Before - when you expect exactly one result
$user = User::where('email', $email)->first();
if (! $user) { throw new Exception; }

// Polished
$user = User::where('email', $email)->sole();
```

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

### 8. Long Methods (> 20-25 lines)
```php
// Unpolished - method doing 5 things
private function processOrder(): void
{
    // 50 lines of validation, calculation,
    // notification, logging, cleanup...
}

// Should be broken into focused methods
```

### 9. Queries Inside Loops (N+1)
```php
// Unpolished - query per iteration
foreach ($posts as $post) {
    $author = User::find($post->user_id);  // N+1!
}
```

### 10. date()/strtotime() Instead of Carbon
```php
// Unpolished
date('Y-m-d', strtotime($model->created_at));

// Use Carbon methods
```

### 11. Error Suppression Operator (@)
```php
// Unpolished - hides problems
@unlink($path);
@file_get_contents($url);
```

### 12. Complex Inline Logic
```php
// Unpolished - logic that needs a name
while ($usedNames->contains($name)) {
    $pathInfo = pathinfo($name);
    // 10 more lines of complexity...
}

// Extract to well-named helper method
```

### 13. foreach with continue/break When Collection Would Work
```php
// Unpolished
foreach ($items as $item) {
    if ($item->invalid) {
        continue;
    }
    $result[] = $item->transform();
}

// Use filter()->map()
```

---

## Output Format

### Review Mode Output

```
## Otwell Polish Report

### Critical (Structural Issues)

1. **ExportJob.php:84** - Method too long (45+ lines)
   `process()` is doing too many things. Break into focused methods.

2. **OrderService.php:52** - N+1 query inside loop
   ```php
   // Current
   foreach ($items as $item) {
       $product = Product::find($item->product_id);
   }

   // Polished
   $products = Product::whereIn('id', $items->pluck('product_id'))->get()->keyBy('id');
   ```

### Should Fix

3. **ReportController.php:28** - Use Carbon, not date()/strtotime()
   ```php
   // Current
   date('Y-m-d', strtotime($model->created_at))

   // Polished
   $model->created_at->toDateString()
   ```

4. **FileHandler.php:67** - Avoid error suppression
   ```php
   // Current
   @unlink($path);

   // Polished
   rescue(fn () => unlink($path));
   ```

### Consider

5. **CleanupJob.php:41** - Use higher-order each
   ```php
   // Current
   $records->each(function ($record) {
       $record->delete();
   });

   // Polished
   $records->each->delete();
   ```

### Already Polished
- Good use of `tap()` at line 23
- Clean guard clause at line 45

### Summary
Found 5 polish opportunities (2 critical, 2 should fix, 1 consider).
```

### Apply Mode Output

```
## Otwell Polish Applied

### Structural Changes

1. **ExportJob.php** - Refactored `process()`
   - Extracted `fetchData()`, `transform()`, `upload()` methods
   - Main method now reads like prose

2. **OrderService.php** - Fixed N+1 query
   - Pre-loaded products before loop

### Code Quality

3. Replaced `date()` with Carbon's `->toDateString()`
4. Replaced `@unlink()` with `rescue()`
5. Simplified deletion with `->each->delete()`

### Summary
Applied 5 polish refinements. Code now has that Otwell touch.
```

---

## Remember

The goal is not to change WHAT the code does, only HOW it reads. Every change should make the code:
- More readable at a glance
- More idiomatic to Laravel
- More consistent with modern PHP
- More beautiful to look at

As Taylor says: "I want every little detail to be totally perfect because I don't feel confident building my own projects on it."
