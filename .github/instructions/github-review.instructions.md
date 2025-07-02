---
applyTo: "**"
---

# Code Review Instructions - Next.js React TypeScript Team

## 🌟 Our Review Philosophy

We believe in constructive, empathetic code reviews that help our team grow together. Every review is an opportunity to learn, teach, and improve our codebase while maintaining a supportive environment.

## 🚀 Technology Stack & Latest Features

### Next.js 14+ Features We Embrace

- **App Router**: Use the new `app` directory structure over `pages`
- **Server Components**: Default to server components, use `'use client'` only when necessary
- **Server Actions**: Leverage server actions for form handling and mutations
- **Streaming & Suspense**: Implement loading states with `loading.tsx` and `<Suspense>`
- **Parallel Routes**: Use `@folder` convention for parallel route segments
- **Intercepting Routes**: Implement modal patterns with `(.)` convention
- **Route Groups**: Organize routes with `(group)` folders without affecting URL structure
- **Dynamic Metadata**: Use `generateMetadata()` for SEO optimization
- **Image Optimization**: Always use `next/image` with proper `sizes` prop
- **Font Optimization**: Use `next/font` for web font optimization

### React 18+ Patterns We Encourage

- **Concurrent Features**: Embrace `useTransition()` and `useDeferredValue()` for better UX
- **Suspense Boundaries**: Implement proper error and loading boundaries
- **Server & Client Components**: Understand the boundary between server and client rendering
- **React Server Components**: Pass serializable props from server to client components
- **Modern Hooks**: Use `useId()` for unique IDs, `useSyncExternalStore()` for external state

### TypeScript Excellence

- **Strict Mode**: Always use `"strict": true` in `tsconfig.json`
- **Type Safety**: Prefer type inference over explicit typing when clear
- **Generic Components**: Use generics for reusable component patterns
- **Utility Types**: Leverage `Pick`, `Omit`, `Partial`, `Required` effectively
- **Template Literal Types**: Use for strongly-typed string patterns
- **Branded Types**: Implement for domain-specific primitives

### Tailwind CSS v4 Best Practices

- **CSS-First Configuration**: Define design tokens, utilities, and variants directly in CSS using `@theme` and cascade layers. Tailwind config files (`tailwind.config.js`) are now optional.
- **Design System**: Use consistent spacing, color, and typography tokens defined via CSS custom properties or `@theme`, aligning with a single source of truth.
- **Component Variants**: Use `clsx` or `cva` (from `class-variance-authority`) to manage complex conditional styling logic cleanly.
- **Custom Utilities**: Extend Tailwind directly via CSS using custom `@utilities` blocks or use modern CSS features like `@property`, `color-mix()`, and logical properties.
- **Responsive Design**: Continue using a mobile-first approach. Breakpoints remain intuitive (`sm:`, `md:`, etc.), and container queries are now supported.
- **Dark Mode**: Use the `class` strategy (`dark:`) with full support for cascade layers and scoped themes.
- **Performance**: Tailwind v4’s JIT engine is faster than ever — no build config required, with automatic content detection and optimized rebuild times.
- **Modern CSS Features**: Leverage built-in support for container queries, cascade layers, logical properties, P3 color space (Oklch), and 3D transforms.
- **Minimal Setup**: Tailwind v4 includes a native Vite plugin, automatic imports, and doesn’t require `content` arrays in config.

## 🎯 KISS, SOLID & DRY Principles for Frontend

### KISS (Keep It Simple, Stupid)

- **Simple Components**: One responsibility per component
- **Clear Naming**: Component and function names should be self-explanatory
- **Minimal Dependencies**: Question every new dependency
- **Readable Code**: Favor clarity over cleverness

```typescript
// ✅ KISS - Simple and clear
const UserCard = ({ user }: { user: User }) => (
  <div className="p-4 border rounded">
    <h3>{user.name}</h3>
    <p>{user.email}</p>
  </div>
);

// ❌ Over-engineered
const EnhancedUserPresentationComponent = memo(
  forwardRef<HTMLDivElement, ComplexUserProps>(({ ...props }, ref) => {
    // Complex logic that could be simplified
  })
);
```

### SOLID Principles for Frontend

#### Single Responsibility Principle (SRP)

```typescript
// ✅ Single responsibility
const UserAvatar = ({ src, alt }: AvatarProps) => (
  <img src={src} alt={alt} className="w-10 h-10 rounded-full" />
);

const UserInfo = ({ user }: { user: User }) => (
  <div>
    <h3>{user.name}</h3>
    <p>{user.email}</p>
  </div>
);

// ❌ Multiple responsibilities
const UserComponent = ({ user }: { user: User }) => {
  // Handles display, data fetching, validation, etc.
};
```

#### Open/Closed Principle (OCP)

```typescript
// ✅ Open for extension, closed for modification
interface ButtonProps {
  variant?: "primary" | "secondary" | "danger";
  size?: "sm" | "md" | "lg";
  children: React.ReactNode;
}

const Button = ({
  variant = "primary",
  size = "md",
  children,
  ...props
}: ButtonProps) => {
  const baseStyles = "px-4 py-2 rounded font-medium";
  const variantStyles = {
    primary: "bg-blue-500 text-white hover:bg-blue-600",
    secondary: "bg-gray-200 text-gray-800 hover:bg-gray-300",
    danger: "bg-red-500 text-white hover:bg-red-600",
  };

  return (
    <button className={`${baseStyles} ${variantStyles[variant]}`} {...props}>
      {children}
    </button>
  );
};
```

#### Liskov Substitution Principle (LSP)

```typescript
// ✅ Substitutable components
interface InputProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}

const TextInput = ({ value, onChange, placeholder }: InputProps) => (
  <input
    type="text"
    value={value}
    onChange={(e) => onChange(e.target.value)}
    placeholder={placeholder}
  />
);

const EmailInput = ({
  value,
  onChange,
  placeholder = "Enter email",
}: InputProps) => (
  <input
    type="email"
    value={value}
    onChange={(e) => onChange(e.target.value)}
    placeholder={placeholder}
  />
);
```

#### Interface Segregation Principle (ISP)

```typescript
// ✅ Focused interfaces
interface Readable {
  read(): string;
}

interface Writable {
  write(data: string): void;
}

interface Deletable {
  delete(): void;
}

// ❌ Fat interface
interface FileOperations {
  read(): string;
  write(data: string): void;
  delete(): void;
  compress(): void;
  encrypt(): void;
  // Too many responsibilities
}
```

#### Dependency Inversion Principle (DIP)

```typescript
// ✅ Depend on abstractions
interface UserRepository {
  findById(id: string): Promise<User>;
  save(user: User): Promise<void>;
}

const UserProfile = ({
  userRepository,
}: {
  userRepository: UserRepository;
}) => {
  const [user, setUser] = useState<User | null>(null);

  useEffect(() => {
    userRepository.findById("123").then(setUser);
  }, [userRepository]);

  return user ? <UserCard user={user} /> : <LoadingSpinner />;
};
```

### DRY (Don't Repeat Yourself)

```typescript
// ✅ DRY - Custom hook for common pattern
const useLocalStorage = <T>(key: string, initialValue: T) => {
  const [value, setValue] = useState<T>(() => {
    if (typeof window === "undefined") return initialValue;
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      return initialValue;
    }
  });

  const setStoredValue = (value: T | ((val: T) => T)) => {
    try {
      setValue(value);
      if (typeof window !== "undefined") {
        window.localStorage.setItem(key, JSON.stringify(value));
      }
    } catch (error) {
      console.error(`Error setting localStorage key "${key}":`, error);
    }
  };

  return [value, setStoredValue] as const;
};

// Usage across components
const useUserPreferences = () =>
  useLocalStorage("userPrefs", defaultPreferences);
const useTheme = () => useLocalStorage("theme", "light");
```

## 🏗️ Domain-Driven Architecture

### Directory Structure

```
src/
├── app/                          # Next.js 14 App Router
│   ├── (auth)/                   # Route group for auth pages
│   │   ├── login/
│   │   └── register/
│   ├── dashboard/
│   │   ├── @analytics/           # Parallel route
│   │   ├── users/
│   │   │   ├── [id]/
│   │   │   │   ├── page.tsx
│   │   │   │   └── @modal/       # Intercepting route
│   │   │   ├── loading.tsx
│   │   │   └── error.tsx
│   │   └── page.tsx
│   ├── globals.css
│   ├── layout.tsx
│   └── page.tsx
├── domains/                      # Domain layer
│   ├── user/
│   │   ├── entities/
│   │   │   ├── User.ts
│   │   │   └── UserPreferences.ts
│   │   ├── repositories/
│   │   │   └── UserRepository.ts
│   │   ├── services/
│   │   │   └── UserService.ts
│   │   └── types/
│   │       └── index.ts
│   ├── auth/
│   └── shared/
│       ├── entities/
│       ├── value-objects/
│       └── events/
├── components/                   # Presentation layer
│   ├── ui/                      # Generic UI components
│   │   ├── button/
│   │   │   ├── Button.tsx
│   │   │   ├── Button.stories.tsx
│   │   │   └── Button.test.tsx
│   │   └── input/
│   ├── features/                # Feature-specific components
│   │   ├── user-profile/
│   │   └── auth/
│   └── layout/
├── hooks/                       # Custom React hooks
├── lib/                        # Utilities and configurations
└── types/                      # Global TypeScript types
```

## 🤝 Empathetic Review Guidelines

### Language & Tone

- **Use "we" instead of "you"**: "We could improve this by..." instead of "You should..."
- **Ask questions**: "What do you think about trying X approach here?"
- **Acknowledge good work**: "Great job implementing the error handling here!"
- **Be specific**: "Consider extracting this logic into a custom hook" vs "This is messy"

### Feedback Categories

#### 🟢 Appreciation (Always include some!)

```markdown
## 🟢 What I Love About This PR

- **Clean architecture**: The separation between domain and infrastructure layers is excellent
- **Type safety**: Great use of branded types for the domain entities
- **Testing**: Comprehensive test coverage with clear test names
- **Accessibility**: Proper ARIA labels and keyboard navigation support
```

#### 🟡 Suggestions (Gentle improvements)

```markdown
## 🟡 Friendly Suggestions

**Performance consideration**: This component re-renders frequently. What are your thoughts on memoizing the expensive calculation?

**Accessibility enhancement**: Would you consider adding a loading state announcement for screen readers?

**Code organization**: I wonder if extracting this business logic into a custom hook might make it more reusable?
```

#### 🔴 Important Issues (Respectful but clear)

```markdown
## 🔴 Important Items to Address

**Security concern**: I noticed the user input isn't sanitized before database storage. This could be a potential XSS risk. What do you think about adding validation here?

**Type safety**: The API response isn't typed, which might cause runtime errors. Could we add a type guard or schema validation?
```

### Review Comment Templates

#### Code Quality

```markdown
**Great abstraction!** 🎉
This custom hook follows the single responsibility principle perfectly. The way you've encapsulated the localStorage logic makes it really reusable across components.

One small suggestion: What do you think about adding error boundaries for the JSON parsing? It would make the hook more robust for edge cases.
```

#### Architecture

```markdown
**Domain-driven approach** 👏
I love how you've separated the domain logic from the infrastructure concerns. This makes our code much more testable and maintainable.

**Quick question**: Have you considered using a factory pattern for creating the User entities? It might help centralize the validation logic.
```

#### Performance

````markdown
**Performance insight** 💡
This component is doing great work! I noticed it might re-render when the parent state changes.

Would you be open to trying `useMemo` for the filtered data? It could help with performance when the list grows larger.

```typescript
const filteredUsers = useMemo(
  () => users.filter((user) => user.isActive),
  [users]
);
```
````

````

#### Accessibility
```markdown
**Accessibility champion!** ♿
Thanks for including proper ARIA labels! Our users with disabilities will really appreciate this attention to detail.

**Small enhancement**: What are your thoughts on adding focus management for the modal? It would complete the accessibility story.
````

## 📝 Code Review Checklist

### Next.js & React Patterns

- [ ] Uses App Router conventions correctly (`app/` directory)
- [ ] Server Components are default, Client Components use `'use client'` directive
- [ ] Server Actions are used for form mutations
- [ ] Proper error boundaries and loading states
- [ ] Image optimization with `next/image` and `sizes` prop
- [ ] Metadata is properly configured
- [ ] Streaming and Suspense are used effectively

### TypeScript Quality

- [ ] Strict mode is enabled and followed
- [ ] Props are properly typed with interfaces
- [ ] Generic types are used appropriately
- [ ] No `any` types (unless absolutely necessary with comment)
- [ ] Domain entities use branded types
- [ ] API responses have proper type guards

### Tailwind CSS

- [ ] Uses design system tokens (spacing, colors, typography)
- [ ] Mobile-first responsive design
- [ ] No hardcoded magic numbers
- [ ] Proper dark mode support
- [ ] Custom utilities are documented

### Architecture & Patterns

- [ ] Domain logic is separated from UI concerns
- [ ] Repository pattern is used for data access
- [ ] Value objects are used for domain primitives
- [ ] Services contain business logic
- [ ] Components follow single responsibility principle

### Performance

- [ ] Unnecessary re-renders are avoided
- [ ] Large lists use virtualization or pagination
- [ ] Images are optimized and properly sized
- [ ] Bundle size impact is considered
- [ ] API calls are properly cached

### Accessibility

- [ ] Semantic HTML is used
- [ ] ARIA labels and roles are proper
- [ ] Keyboard navigation works
- [ ] Color contrast meets WCAG guidelines
- [ ] Screen reader announcements are appropriate

### Testing

- [ ] Unit tests cover business logic
- [ ] Integration tests cover user flows
- [ ] Test names are descriptive
- [ ] Edge cases are tested
- [ ] Mocks are used for external dependencies

## 🌈 Remember: Code Reviews Are About Growth

Every review is a chance to:

- **Learn** something new from your teammate
- **Share** knowledge and best practices
- **Improve** our codebase together
- **Build** stronger team relationships
- **Celebrate** good work and creative solutions

Let's keep our reviews constructive, kind, and focused on making our code and team better! 💪✨

---

_"The best code reviews feel like pair programming sessions - collaborative, educational, and encouraging."_
