# Otwell Polish

Apply the artisanal code refinement that Taylor Otwell brings to Laravel - the code that elevates good code to great code. This is the craft of leaving code better than you found it.

## Context Gathering

1. Be smart about what to polish. The user may reference one or more files - use those. If they don't, start with with uncommited changes first:
   ```bash
   # Check for uncommitted changes first
   git diff --name-only
   git diff --name-only --cached
   ```

2. If changes exist, review those PHP files. If not, determine the difference between the current branch and main/master:
   ```bash
   git fetch origin main
   git diff --name-only origin/main
   ```

## Modes

### Review Mode (Default)

Invoked with `/otwell-polish` or `/otwell-polish <file/path>`

Analyze code and identify polish opportunities WITHOUT making changes. Put in a numbered list with code snippets showing before/after.

The user will likely instruct you in picking and choosing which suggestions to apply in response to your review.

---

## The Otwell Philosophy

Taylor Otwell's philosophy:

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

### 11. Modern PHP Features

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
$slug = Str::slug($title);
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
    $slug = Str::slug($title);

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

### 23. Fluent Interfaces (Builder Pattern)

Classes that return `$this` so method calls chain together like sentences. Laravel is built on them: query builder, mail, notifications, pipelines, pending dispatches. When building custom classes, prefer a fluent API over setters or config arrays.

**Return `$this` from configuration methods:**

```php
// Before - setter-style configuration
$report = new ReportBuilder;
$report->setType('sales');
$report->setDateRange($start, $end);
$report->setFormat('pdf');
$report->setRecipient($user);
$result = $report->generate();

// Polished - fluent builder
$result = ReportBuilder::make()
    ->type('sales')
    ->dateRange($start, $end)
    ->format('pdf')
    ->recipient($user)
    ->generate();
```

**Use a static `make()` or `for()` entry point for readability:**

```php
// Before - new + configure
$invitation = new Invitation;
$invitation->team_id = $team->id;
$invitation->email = $email;
$invitation->role = 'member';
$invitation->save();

// Polished - fluent factory
$invitation = Invitation::for($team)
    ->email($email)
    ->role('member')
    ->send();
```

**Follow Laravel's own patterns — Mail, Notifications, Pipelines:**

```php
// Mail builder - Taylor's signature style
Mail::to($user)
    ->cc($managers)
    ->bcc($admin)
    ->queue(new MonthlyReport($data));

// Notification builder
$user->notify(
    Notification::make()
        ->title('Export Complete')
        ->body('Your report is ready.')
        ->action('Download', $url)
);

// Pipeline - process through steps fluently
$result = Pipeline::send($request)
    ->through([
        NormalizeInput::class,
        ValidateData::class,
        TransformPayload::class,
    ])
    ->thenReturn();
```

**Building your own fluent class — the pattern:**

```php
class DeploymentBuilder
{
    private string $branch = 'main';
    private string $environment = 'production';
    private bool $migrate = false;
    private array $hooks = [];

    public static function make(): static
    {
        return new static;
    }

    public function branch(string $branch): static
    {
        $this->branch = $branch;

        return $this;
    }

    public function to(string $environment): static
    {
        $this->environment = $environment;

        return $this;
    }

    public function withMigrations(): static
    {
        $this->migrate = true;

        return $this;
    }

    public function afterDeploy(Closure $hook): static
    {
        $this->hooks[] = $hook;

        return $this;
    }

    public function run(): DeploymentResult
    {
        // Terminal method - does the work
    }
}

// Usage reads like prose:
DeploymentBuilder::make()
    ->branch('feature/new-dashboard')
    ->to('staging')
    ->withMigrations()
    ->afterDeploy(fn () => Artisan::call('cache:clear'))
    ->run();
```

**Key principles of Otwell-style fluent APIs:**

- **Static entry point** — `make()`, `for()`, `query()`, `build()` — avoids awkward `new` in chains
- **Verb-style terminal methods** — `send()`, `run()`, `dispatch()`, `get()` — the last call does the work
- **Boolean toggles read as phrases** — `->withMigrations()` over `->setMigrate(true)`
- **Preposition methods for context** — `->to('staging')`, `->for($user)`, `->via('slack')`
- **Return `static` not `self`** — allows subclasses to chain without breaking the type
- **Sensible defaults** — the builder should work with minimal configuration

**Spot opportunities to refactor config arrays into builders:**

```php
// Before - config array (hard to read, no IDE support)
$this->export([
    'type' => 'csv',
    'columns' => ['name', 'email'],
    'filter' => fn ($q) => $q->where('active', true),
    'filename' => 'users-export',
    'disk' => 's3',
]);

// Polished - fluent builder
Export::make()
    ->csv()
    ->columns(['name', 'email'])
    ->query(fn ($q) => $q->where('active', true))
    ->filename('users-export')
    ->toDisk('s3');
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

### 7. Long Methods (> 20-25 lines)
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

### 14. Boolean Flag Arguments
Boolean arguments are unreadable at the call site. What does `true` mean here? Nobody knows without reading the method signature.

Consider chaining (see fluent interfaces above) or descriptive methods instead.

```php
// Unpolished - what does true mean?
$user->notify($message, true);
$order->process(false, true);
$report->generate(true);

// Polished - use descriptive methods instead
$user->notifyImmediately($message);
$order->processWithoutReceipt()->withTracking();
$report->generateAsPdf();

// Or use named arguments (PHP 8.0+)
$user->notify($message, immediately: true);

// Or use enums for multi-state flags
$report->generate(Format::Pdf);
```

Never use boolean parameters. They are the antithesis of code that reads like prose. Every `true`/`false` at a call site is a readability failure. Instead:
- **Split into two methods** — `send()` / `sendQuietly()`, `delete()` / `forceDelete()`
- **Use named arguments** — if the bool truly belongs, at least make it readable
- **Use enums** — when the flag represents a choice between states
- **Use fluent toggles** — `->withTimestamps()`, `->withoutTouching()`

Laravel itself follows this — `$model->delete()` vs `$model->forceDelete()`, `Str::of($val)->lower()` not `Str::convert($val, true)`.

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
