# Twelve-Factor App

Core principles for building software-as-a-service applications that are portable, scalable, and operationally sound.

| Factor | Principle |
|--------|-----------|
| I. Codebase | One codebase tracked in version control, many deploys. Every deploy (staging, production) runs from the same repo. |
| II. Dependencies | Explicitly declare and isolate all dependencies. Never rely on system-wide packages. Use lock files. |
| III. Config | Store config in environment variables. Config varies between deploys; code does not. Never commit credentials. |
| IV. Backing Services | Treat databases, caches, queues, and email services as attached resources, swappable via config without code changes. |
| V. Build, Release, Run | Strictly separate the build stage (compile + bundle), release stage (build + config), and run stage (execute). Releases are immutable and append-only. |
| VI. Processes | Execute the app as one or more stateless processes. Persistent data lives in backing services, never in process memory or local filesystem. |
| VII. Port Binding | Export services via port binding. The app is self-contained and does not depend on a runtime web server injection. |
| VIII. Concurrency | Scale out via the process model. Different process types handle different workloads (web, worker, scheduler). |
| IX. Disposability | Maximize robustness with fast startup and graceful shutdown. Processes can be started, stopped, or restarted at a moment's notice. |
| X. Dev/Prod Parity | Keep development, staging, and production as similar as possible. Minimize time gap, personnel gap, and tools gap between environments. |
| XI. Logs | Treat logs as event streams. Write to stdout; let the execution environment handle routing, storage, and aggregation. |
| XII. Admin Processes | Run admin and management tasks (migrations, REPL, one-off scripts) as one-off processes in the same environment with the same codebase and config. |
