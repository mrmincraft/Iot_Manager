# Diagrammes des dépendances - IoT Connection Manager

## 1️⃣ Diagramme d'architecture en couches

```mermaid
graph TB
    P["🎨 PRESENTATION<br/>Pages, ViewModels, Widgets"]
    D["🧠 DOMAIN<br/>Entities, UseCases, Repos (I)"]
    DA["💾 DATA<br/>Models, DataSources, Impl"]
    C["🔧 CORE<br/>DI, Events, Utils, Exceptions"]
    
    P --> D
    P --> C
    D --> C
    DA --> D
    DA --> C
    
    style P fill:#e1f5ff,stroke:#1976d2,stroke-width:2px
    style D fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style DA fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style C fill:#fff3e0,stroke:#f57c00,stroke-width:2px
```


## 2️⃣ Flux des données (Data Flow)

```mermaid
graph LR
    UI["🖥️ UI<br/>(User Interaction)"]
    VM["📱 ViewModel<br/>(State Management)"]
    UC["⚙️ UseCase<br/>(Business Logic)"]
    Repo["📦 Repository<br/>(Data Access)"]
    DS["💾 DataSource<br/>(SQLite)"]
    DB[(SQLite<br/>Database)]
    
    UI -->|Handle Event| VM
    VM -->|Execute| UC
    UC -->|Call| Repo
    Repo -->|Query| DS
    DS -->|Read/Write| DB
    
    DB -->|Return Data| DS
    DS -->|Model → Entity| Repo
    Repo -->|Success/Failure| UC
    UC -->|Publish Event| EventBus["📡 EventBus"]
    EventBus -->|Notify| VM
    VM -->|Update State| UI
    
    style UI fill:#e1f5ff
    style VM fill:#f3e5f5
    style UC fill:#f3e5f5
    style Repo fill:#e8f5e9
    style DS fill:#e8f5e9
    style DB fill:#fff3e0
    style EventBus fill:#fff3e0
```

## 3️⃣ Dépendances des UseCases

```mermaid
graph TB
    DUC["🔧 Device UseCases<br/>GetAll, Add, Update, Delete, Search"]
    CUC["🔧 Connection UseCases<br/>Connect, Disconnect, GetStatus"]
    CMUC["🔧 Command UseCases<br/>Send, GetHistory"]
    Repos["📦 Repositories<br/>Device, Connection, Command"]
    EB["📡 EventBus"]
    
    DUC --> Repos
    CUC --> Repos
    CMUC --> Repos
    
    DUC --> EB
    CUC --> EB
    CMUC --> EB
    
    style DUC fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style CUC fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style CMUC fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style Repos fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style EB fill:#fff3e0,stroke:#f57c00,stroke-width:2px
```

## 4️⃣ Cycle de vie des événements

```mermaid
sequenceDiagram
    actor User
    participant UI as Page/Widget
    participant VM as ViewModel
    participant UC as UseCase
    participant Repo as Repository
    participant DS as DataSource
    participant DB as SQLite
    participant EB as EventBus
    
    User->>UI: Clique sur un bouton
    UI->>VM: appelle une méthode
    VM->>VM: isLoading = true
    VM->>UC: execute()
    UC->>Repo: appelle une méthode
    Repo->>DS: query()
    DS->>DB: SELECT/INSERT/UPDATE
    DB-->>DS: Résultat
    DS-->>Repo: Model → Entity
    Repo-->>UC: Result<Entity>
    UC->>EB: publish(Event)
    UC-->>VM: Retour Result
    
    EB->>VM: onEvent()
    VM->>VM: Update State
    VM->>VM: isLoading = false
    VM->>UI: notifyListeners()
    UI->>UI: rebuild()
    UI-->>User: ✅ UI Mise à jour
```

## 5️⃣ Architecture MVVM - Flux détaillé

```mermaid
graph TB
    subgraph "MVVM Pattern"
        direction LR
        Model["Model<br/>(Domain Entities)"]
        ViewModel["ViewModel<br/>- State notifiers<br/>- Event handlers<br/>- Use case execution"]
        View["View<br/>(UI Layer)<br/>- Pages<br/>- Widgets<br/>- Listeners"]
    end
    
    Model ---|Passed via constructor| ViewModel
    ViewModel ---|Observes state changes| View
    View ---|User interactions| ViewModel
    ViewModel ---|Queries/Updates| Model
    
    style Model fill:#f3e5f5
    style ViewModel fill:#f3e5f5
    style View fill:#e1f5ff
```

## 6️⃣ Injection de dépendances

```mermaid
graph TB
    Sing["🔧 Singletons<br/>EventBus, Logger, DB"]
    Repos["📦 Repositories<br/>Device, Connection, Command"]
    UseCases["⚙️ UseCases<br/>GetAll, Add, Connect"]
    ViewModels["📱 ViewModels<br/>List, Connection"]
    
    UseCases --> Repos
    Repos --> Sing
    ViewModels --> UseCases
    
    style Sing fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Repos fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style UseCases fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style ViewModels fill:#e1f5ff,stroke:#1976d2,stroke-width:2px
```

## 7️⃣ Relations entre les couches (Dependency Rules)

```mermaid
graph TB
    P["🎨 PRESENTATION<br/>Pages, ViewModels, Widgets"]
    D["🧠 DOMAIN<br/>Entities, UseCases, Repositories"]
    DA["💾 DATA<br/>Models, DataSources, Impl"]
    C["🔧 CORE<br/>DI, Events, Utils, Exceptions"]
    
    P -->|depends| D
    P -->|depends| C
    D -->|depends| C
    DA -->|implements| D
    DA -->|depends| C
    
    P -.->|NO DIRECT ACCESS| DA
    DA -.->|NO REVERSE| P
    
    style P fill:#e1f5ff,stroke:#1976d2,stroke-width:2px
    style D fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style DA fill:#e8f5e9,stroke:#388e3c,stroke-width:2px
    style C fill:#fff3e0,stroke:#f57c00,stroke-width:2px
```

## 8️⃣ Event Bus - Architecture complète

```mermaid
graph TB
    Pub["📤 Publishers<br/>UseCases, Repositories"]
    Publish["📡 publish()"]
    Listeners["Listeners Map<br/>Type → Handlers"]
    Subscribe["✋ subscribe<T>()"]
    Sub["📥 Subscribers<br/>ViewModels, Widgets"]
    
    Pub -->|Publish Event| Publish
    Publish --> Listeners
    Subscribe --> Listeners
    Listeners -->|Dispatch to all| Sub
    
    style Pub fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    style Publish fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Listeners fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Subscribe fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    style Sub fill:#e1f5ff,stroke:#1976d2,stroke-width:2px
```

## 9️⃣ SQLite Schema - Relations

```mermaid
erDiagram
    DEVICES ||--o{ CONNECTIONS : has
    DEVICES ||--o{ COMMANDS : receives
    
    DEVICES {
        text id PK
        text name
        text type
        text address
        text status
        text metadata
        integer created_at
        integer updated_at
    }
    
    CONNECTIONS {
        text id PK
        text device_id FK
        text status
        integer signal_strength
        integer connected_at
        integer disconnected_at
        text last_error
    }
    
    COMMANDS {
        text id PK
        text device_id FK
        text command_type
        text parameters
        text status
        text response
        integer sent_at
        integer executed_at
        text error
    }
```

## 🔟 Platform-specific Considerations

```mermaid
graph TB
    subgraph "IoT Connection Manager"
        Core["Core Architecture<br/>(Platform Independent)"]
    end
    
    subgraph "Platforms"
        direction LR
        Android["🤖 Android<br/>SQLite native<br/>Native communication"]
        iOS["🍎 iOS<br/>SQLite native<br/>Native communication"]
        Windows["🪟 Windows<br/>SQLite native<br/>Native communication"]
        Linux["🐧 Linux<br/>SQLite native<br/>Native communication"]
        macOS["🍎 macOS<br/>SQLite native<br/>Native communication"]
    end
    
    Core ---|Shared Code| Android
    Core ---|Shared Code| iOS
    Core ---|Shared Code| Windows
    Core ---|Shared Code| Linux
    Core ---|Shared Code| macOS
    
    style Core fill:#f3e5f5
    style Android fill:#e1f5ff
    style iOS fill:#e1f5ff
    style Windows fill:#e1f5ff
    style Linux fill:#e1f5ff
    style macOS fill:#e1f5ff
```

