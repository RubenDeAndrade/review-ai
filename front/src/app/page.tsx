import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-b from-white to-gray-50 dark:from-gray-900 dark:to-gray-800 font-[family-name:var(--font-geist-sans)]">
      {/* Header */}
      <header className="container mx-auto py-6 px-4 flex justify-between items-center">
        <div className="flex items-center gap-2">
          <Image
            src="/file.svg"
            alt="Review AI Logo"
            width={28}
            height={28}
            className="dark:invert"
          />
          <h1 className="text-xl font-bold">Review AI</h1>
        </div>
        <nav>
          <ul className="flex gap-6">
            <li>
              <Link
                href="#features"
                className="hover:text-blue-600 dark:hover:text-blue-400"
              >
                Features
              </Link>
            </li>
            <li>
              <Link
                href="#demo"
                className="hover:text-blue-600 dark:hover:text-blue-400"
              >
                Demo
              </Link>
            </li>
            <li>
              <Link
                href="#getstarted"
                className="hover:text-blue-600 dark:hover:text-blue-400"
              >
                Get Started
              </Link>
            </li>
          </ul>
        </nav>
      </header>

      {/* Hero Section */}
      <main className="flex-grow">
        <section className="container mx-auto px-4 py-12 md:py-24 flex flex-col items-center text-center">
          <h2 className="text-4xl md:text-6xl font-bold mb-6">
            Automated Pull Request Reviews
          </h2>
          <p className="text-xl md:text-2xl text-gray-600 dark:text-gray-300 max-w-2xl mb-10">
            Enhance your code quality with AI-powered reviews that follow your
            team&apos;s standards
          </p>

          <div className="bg-white dark:bg-gray-800 p-6 rounded-lg shadow-lg w-full max-w-4xl mb-12">
            <div className="bg-gray-100 dark:bg-gray-700 rounded-md p-4 mb-4 flex items-center gap-2 text-sm">
              <span className="text-green-600 dark:text-green-400">✓</span>
              <span className="font-mono">Running PR Review on #1234</span>
            </div>
            <div className="border-l-4 border-blue-500 pl-4 py-2 mb-4">
              <h3 className="font-bold mb-2">🟢 What I Love About This PR</h3>
              <ul className="list-disc list-inside text-sm text-left">
                <li>
                  Clean separation of concerns in the component architecture
                </li>
                <li>Excellent TypeScript typing with proper interfaces</li>
                <li>Proper use of React Server Components</li>
              </ul>
            </div>
            <div className="border-l-4 border-yellow-500 pl-4 py-2 mb-4">
              <h3 className="font-bold mb-2">🟡 Friendly Suggestions</h3>
              <ul className="list-disc list-inside text-sm text-left">
                <li>
                  Consider extracting this logic into a custom hook for
                  reusability
                </li>
                <li>
                  Adding proper error boundaries would improve user experience
                </li>
              </ul>
            </div>
          </div>

          <div className="flex gap-4 flex-col sm:flex-row">
            <a
              className="rounded-full bg-blue-600 text-white hover:bg-blue-700 transition-colors px-6 py-3 font-medium"
              href="#getstarted"
            >
              Get Started
            </a>
            <a
              className="rounded-full border border-gray-300 dark:border-gray-600 hover:bg-gray-100 dark:hover:bg-gray-700 transition-colors px-6 py-3 font-medium"
              href="#demo"
            >
              View Demo
            </a>
          </div>
        </section>

        {/* Features Section */}
        <section id="features" className="bg-white dark:bg-gray-800 py-16">
          <div className="container mx-auto px-4">
            <h2 className="text-3xl font-bold text-center mb-12">
              Key Features
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="p-6 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div className="w-12 h-12 bg-blue-100 dark:bg-blue-900 rounded-full flex items-center justify-center mb-4">
                  <Image
                    src="/file.svg"
                    alt="Code Standards"
                    width={24}
                    height={24}
                    className="dark:invert"
                  />
                </div>
                <h3 className="text-xl font-bold mb-2">Code Standards</h3>
                <p className="text-gray-600 dark:text-gray-300">
                  Enforce your team&apos;s coding standards automatically with
                  each review
                </p>
              </div>
              <div className="p-6 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div className="w-12 h-12 bg-green-100 dark:bg-green-900 rounded-full flex items-center justify-center mb-4">
                  <Image
                    src="/window.svg"
                    alt="Customizable Feedback"
                    width={24}
                    height={24}
                    className="dark:invert"
                  />
                </div>
                <h3 className="text-xl font-bold mb-2">
                  Customizable Feedback
                </h3>
                <p className="text-gray-600 dark:text-gray-300">
                  Tailor reviews to be as detailed or concise as you prefer
                </p>
              </div>
              <div className="p-6 border border-gray-200 dark:border-gray-700 rounded-lg">
                <div className="w-12 h-12 bg-purple-100 dark:bg-purple-900 rounded-full flex items-center justify-center mb-4">
                  <Image
                    src="/globe.svg"
                    alt="VS Code Integration"
                    width={24}
                    height={24}
                    className="dark:invert"
                  />
                </div>
                <h3 className="text-xl font-bold mb-2">VS Code Integration</h3>
                <p className="text-gray-600 dark:text-gray-300">
                  Review PRs directly from your VS Code environment
                </p>
              </div>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="bg-gray-100 dark:bg-gray-900 py-8">
        <div className="container mx-auto px-4 text-center text-sm text-gray-600 dark:text-gray-400">
          <p>© 2025 Review AI. All rights reserved.</p>
          <div className="flex justify-center gap-6 mt-4">
            <a
              href="#"
              className="hover:text-blue-600 dark:hover:text-blue-400"
            >
              Documentation
            </a>
            <a
              href="#"
              className="hover:text-blue-600 dark:hover:text-blue-400"
            >
              GitHub
            </a>
            <a
              href="#"
              className="hover:text-blue-600 dark:hover:text-blue-400"
            >
              Contact
            </a>
          </div>
        </div>
      </footer>
    </div>
  );
}
