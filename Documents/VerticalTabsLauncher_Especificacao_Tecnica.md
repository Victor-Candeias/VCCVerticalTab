# Vertical Tabs Launcher — Especificação técnica e plano de desenvolvimento

**Versão:** 1.0  
**Plataforma:** Android 10+ (API 29; confirmar suporte nas bibliotecas escolhidas)  
**Stack:** Kotlin, Jetpack Compose, Coroutines/Flow, Hilt, DataStore, Room, WorkManager  
**Objetivo:** Launcher alternativo com navegação por separadores verticais, imagem de fundo configurável, widgets, organização de aplicações e consumo reduzido de recursos.

> Este documento descreve uma proposta de implementação, não uma aplicação já desenvolvida. As imagens conceptuais são referências visuais, não ecrãs funcionais.

## 1. Visão do produto

O Vertical Tabs Launcher substitui o ecrã inicial tradicional por uma **barra lateral de separadores** sempre acessível e uma **área de conteúdo** que muda de acordo com o separador selecionado. A experiência deve ser fluida, acessível, totalmente configurável e funcional offline, exceto nas integrações que exigem rede.

### Princípios

1. **Navegação imediata:** um toque para trocar de área.
2. **Personalização profunda:** separadores, cores, dimensões, fundos, gestos e widgets.
3. **Privacidade:** dados e configurações locais por defeito; permissões solicitadas apenas quando necessárias.
4. **Eficiência:** sem serviço permanente para atualizações triviais; cache e carregamento diferido.
5. **Compatibilidade:** respeitar as limitações do launcher, do fabricante e da versão Android.

## 2. Ecrãs e navegação

| Ecrã / separador | Conteúdo principal | Ações |
|---|---|---|
| **Início** | Relógio, data, meteorologia, pesquisa, favoritos, agenda resumida | Abrir apps, editar cartões, mudar fundo |
| **Aplicações** | Grelha ou lista de apps instaladas, recentes, categorias | Pesquisar, ordenar, fixar, ocultar da interface, abrir informações |
| **Widgets** | Widgets internos e widgets Android de terceiros | Adicionar, configurar, mover, redimensionar, remover |
| **Agenda** | Calendário mensal e próximos eventos | Filtrar calendários, abrir evento na app de origem |
| **Ferramentas** | Atalhos, ações rápidas e utilitários | Abrir definições do sistema, lanterna quando suportada |
| **Separadores personalizados** | Conjuntos de aplicações, atalhos e widgets | Criar, renomear, reordenar, duplicar, apagar |
| **Definições** | Aparência, comportamento, permissões, backup, diagnóstico | Alterar e exportar configuração |

### Comportamento da barra vertical

- Posicionamento à esquerda ou direita; opção de ocultação automática.
- Largura compacta/normal/larga; ícones com ou sem legendas.
- Separador ativo realçado por cor, fundo ou indicador lateral.
- Suporte a scroll se existirem muitos separadores.
- Reordenação dos separadores por drag-and-drop no modo de edição.
- Alternativa acessível para navegação por toque e TalkBack.
- Em modo paisagem, adaptar largura e espaçamento da barra.

## 3. Personalização completa

### 3.1 Imagem de fundo

- Seleção de imagem da galeria pelo **Android Photo Picker** ou seletor de documentos.
- Fundos incluídos na aplicação; cor sólida e gradiente como alternativas.
- Fundo global ou específico por separador.
- Ajuste: preencher, conter, centrar e recorte manual.
- Opções: brilho, escurecimento, desfoque (quando tecnicamente viável), sobreposição de cor e opacidade.
- Pré-visualização antes de guardar; opção de restaurar o padrão.
- Persistência da imagem com URI autorizada ou cópia privada otimizada; tratar perda de permissões e ficheiros removidos.
- Evitar carregar bitmaps originais de resolução elevada na memória; gerar versões reduzidas adequadas ao ecrã.
- **Opcional pós-MVP:** fundos dinâmicos por horário, sem animação contínua.

### 3.2 Aparência

- Tema claro, escuro ou seguir sistema.
- Cor de destaque e paletas predefinidas.
- Transparência e arredondamento de cartões.
- Tamanho de ícones, densidade da grelha e espaçamento.
- Fonte e escala tipográfica (respeitar definições de acessibilidade).
- Estilo da barra lateral: sólido, translúcido ou minimalista.
- Mostrar/ocultar etiquetas das aplicações.
- Efeitos de transição: nenhum, fade, slide; respeitar animações reduzidas.

### 3.3 Organização

- Separadores predefinidos e personalizados.
- Apps favoritas, atalhos, pastas e categorias definidas pelo utilizador.
- Reordenação manual de aplicações e cartões.
- Ocultar apps apenas da interface do launcher (não desinstalar nem proteger o acesso).
- Ordenação alfabética, por utilização quando houver acesso autorizado, ou manual.
- Exportação e importação de configurações.

### 3.4 Gestos

- Deslizar vertical/horizontalmente para mudar de separador, com opção de desativar.
- Deslizar para cima: gaveta de aplicações.
- Deslizar para baixo: pesquisa ou painel de notificações quando permitido.
- Duplo toque: ação configurável (não prometer bloqueio sem permissões/API adequadas).
- Toque prolongado: entrar em modo de edição.
- Resolver conflitos com gestos de navegação do Android e widgets interativos.

## 4. Widgets e cartões

### Widgets internos

1. **Relógio:** hora e data, 12/24h, formatos regionais.
2. **Meteorologia:** estado atual, temperatura, previsão resumida, cidade manual ou localização autorizada.
3. **Agenda:** próximos eventos, mediante `READ_CALENDAR`.
4. **Bateria:** percentagem e estado de carregamento.
5. **Atalhos:** aplicações e intents suportadas.

### Widgets externos

- Integrar `AppWidgetHost`, `AppWidgetManager` e `AppWidgetHostView` na camada Android View.
- Incorporar o `AppWidgetHostView` em Compose através de `AndroidView`.
- Implementar fluxo de seleção, vinculação (`ACTION_APPWIDGET_BIND`) e configuração do fornecedor quando aplicável.
- Guardar `appWidgetId`, provider, separador, posição e dimensões.
- Chamar `deleteAppWidgetId()` ao remover widgets e gerir ciclo de vida do host.
- Não assumir que widgets externos podem ser estilizados ou atualizados pelo launcher.

### Live cards

Os cartões próprios do launcher podem atualizar dados locais de forma reativa. Meteorologia e outros dados de rede usam cache e WorkManager; o relógio deve recorrer a mecanismos eficientes de atualização de hora, evitando polling por segundo.

## 5. Arquitetura recomendada

```text
VerticalTabsLauncher/
├── app/                       # Activity HOME, DI, navegação e inicialização
├── core/
│   ├── model/                 # Tipos e contratos comuns
│   ├── database/              # Room
│   ├── datastore/             # Preferências globais
│   ├── design/                # Tema, componentes e tokens
│   ├── platform/              # PackageManager, LauncherApps, widgets
│   └── common/                # Result, dispatchers, logging
├── feature/
│   ├── home/
│   ├── apps/
│   ├── tabs/
│   ├── widgets/
│   ├── calendar/
│   ├── tools/
│   ├── wallpaper/
│   ├── settings/
│   └── backup/
└── data/
    ├── weather/
    ├── applications/
    └── calendar/
```

Para um MVP individual, pode começar num único módulo `app` com a mesma organização por packages, separando módulos Gradle apenas quando justificar.

**Padrão:** MVVM + Repository + Use Cases apenas onde acrescentem clareza.  
**UI:** Compose, Navigation Compose, Material 3 customizado.  
**Estado:** StateFlow; persistência Room/DataStore.  
**Concorrência:** coroutines, Dispatchers adequados e cancelamento ligado ao ciclo de vida.  
**Injeção:** Hilt.  
**Rede:** Retrofit/OkHttp, com timeouts e cache.  
**Tarefas periódicas:** WorkManager, respeitando limites de periodicidade e Doze.

### Fluxo de dados

```text
Android APIs / Open-Meteo / CalendarContract
               ↓
        Repositories + Cache
               ↓
       ViewModels / StateFlow
               ↓
 Compose Screens + AppWidgetHostView
```

## 6. Modelo de dados (Room)

| Entidade | Campos sugeridos |
|---|---|
| `TabEntity` | `id`, `title`, `icon`, `position`, `enabled`, `backgroundId`, `layoutMode` |
| `TabItemEntity` | `id`, `tabId`, `type`, `packageName`, `componentName`, `folderId`, `position`, `spanX`, `spanY` |
| `FolderEntity` | `id`, `tabId`, `name`, `color`, `position` |
| `FolderItemEntity` | `id`, `folderId`, `componentName`, `position` |
| `WidgetEntity` | `appWidgetId`, `tabId`, `provider`, `position`, `spanX`, `spanY` |
| `WallpaperEntity` | `id`, `uriOrPath`, `crop`, `blur`, `dim`, `overlayColor` |
| `WeatherCacheEntity` | `locationKey`, `temperature`, `weatherCode`, `updatedAt` |
| `LocationEntity` | `id`, `name`, `latitude`, `longitude`, `timezone` |

**DataStore:** `themeMode`, `accentColor`, `sidebarSide`, `sidebarWidth`, `showLabels`, `gestureMappings`, `weatherUnits`, `animationLevel`, `defaultTabId`.

Regras: chaves estrangeiras, índices em `tabId`/`position`, migrações versionadas, unicidade de IDs de widget e integridade ao apagar separadores/pastas.

## 7. Integrações Android e Manifest

### Launcher predefinido

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.HOME" />
        <category android:name="android.intent.category.DEFAULT" />
    </intent-filter>
</activity>
```

- Usar `RoleManager.ROLE_HOME` em versões compatíveis para solicitar seleção como launcher.
- Descobrir aplicações com `LauncherApps`/`PackageManager` e cumprir as regras de visibilidade de pacotes (`<queries>` ou `QUERY_ALL_PACKAGES` apenas quando justificado e permitido pela política de distribuição).
- Tratar perfis de trabalho, apps desativadas e alterações de pacotes.
- Nunca pressupor controlo sobre a barra de estado, ecrã de bloqueio ou navegação do sistema.

### Permissões e privacidade

| Permissão / API | Uso | Obrigatória? |
|---|---|---|
| `INTERNET` | Meteorologia | Só para funcionalidade online |
| `ACCESS_NETWORK_STATE` | Estado de rede | Não para launcher básico |
| `ACCESS_COARSE_LOCATION` | Cidade aproximada | Não; cidade manual alternativa |
| `READ_CALENDAR` | Eventos locais | Não; pedir ao ativar agenda |
| `AppWidgetHost` | Widgets de terceiros | Fluxo de consentimento do sistema |
| `POST_NOTIFICATIONS` | Alertas opcionais | Não para MVP |

Não recolher telemetria identificável por defeito. Guardar dados localmente e oferecer limpeza de cache e eliminação de dados.

## 8. Meteorologia

**Fonte inicial:** Open-Meteo (verificar licença, limites e condições de utilização antes da distribuição).

Exemplo:

```http
GET https://api.open-meteo.com/v1/forecast?latitude=38.72&longitude=-9.14&current=temperature_2m,weather_code&daily=temperature_2m_max,temperature_2m_min,weather_code&timezone=auto
```

- Coordenadas ilustrativas; usar cidade selecionada pelo utilizador.
- Mapear `weather_code` para ícones locais (sol, nublado, chuva, neve, trovoada).
- Atualizar aproximadamente a cada 30–60 minutos, quando permitido; apresentar timestamp da última atualização.
- Fallback offline para a última leitura e tratamento de erros/retries.

## 9. Desempenho e consumo reduzido

**Objetivos de teste, não garantias:**

- Tempo de abertura do ecrã inicial: meta inferior a 300 ms em dispositivo de referência após warm start.
- CPU em repouso: próximo de zero, sem loops de atualização contínuos.
- Memória: estabelecer baseline real e procurar minimizar PSS e retenções.
- Scroll fluido com listas lazy e itens de chave estável.
- Descodificar wallpapers na resolução necessária e evitar bitmaps gigantes.
- Carregar ícones sob demanda com cache LRU limitada.
- Evitar blur em tempo real em toda a superfície, vídeos de fundo e efeitos 3D permanentes.
- Atualizar widgets apenas quando os dados mudam ou quando o sistema o solicita.
- Medir com Android Studio Profiler, Macrobenchmark e Perfetto.

## 10. Roadmap de desenvolvimento

| Fase | Entregas | Critério de conclusão |
|---|---|---|
| **0 — Fundação** | Projeto, Manifest HOME, tema, DI, persistência | Pode ser selecionado como launcher e recupera após reinício |
| **1 — Navegação vertical** | Barra lateral, Início, Apps, pesquisa e favoritos | Abrir qualquer app instalada; separadores navegáveis |
| **2 — Personalização** | Wallpaper, temas, tamanhos, cores, configuração da barra | Definições persistem e restauram corretamente |
| **3 — Organização** | Separadores personalizados, pastas, reordenação e gestos | Editor estável e acessível |
| **4 — Widgets** | Widgets internos e AppWidgetHost | Adicionar, configurar, redimensionar e remover widgets |
| **5 — Integrações** | Meteorologia, agenda, permissões e cache | Funciona offline com dados em cache |
| **6 — Qualidade** | Testes, backup, métricas, release | Sem crashes críticos e consumo validado |

**MVP recomendado:** fases 0–2, com relógio/data e wallpaper configurável. Widgets externos e personalização avançada entram na fase seguinte.

## 11. Backlog funcional por prioridade

### P0 — Essencial

- [ ] Registo como launcher HOME e seleção como predefinido.
- [ ] Barra vertical configurável (posição, largura e ícones).
- [ ] Ecrãs Início, Aplicações e Definições.
- [ ] Pesquisa e abertura de aplicações instaladas.
- [ ] Favoritos e persistência.
- [ ] Imagem de fundo personalizada, com recorte e escurecimento.
- [ ] Tema claro/escuro e cor de destaque.
- [ ] Relógio e data locais.

### P1 — Versão completa

- [ ] Separadores personalizados e reordenação.
- [ ] Pastas e arrastar/largar.
- [ ] Widgets Android de terceiros.
- [ ] Meteorologia e agenda.
- [ ] Gestos configuráveis.
- [ ] Importação/exportação de configurações.

### P2 — Diferenciação

- [ ] Fundos diferentes por separador.
- [ ] Perfis Casa/Trabalho/Viagem, ativados manualmente.
- [ ] Layouts alternativos (lista, grelha, cartões).
- [ ] Editor visual com pré-visualização em tempo real.
- [ ] Temas partilháveis sem executar código externo.

## 12. Testes e critérios de aceitação

### Funcionais

- Instalar, selecionar e retirar como launcher predefinido.
- Abrir aplicações e regressar ao ecrã inicial.
- Instalar/desinstalar apps e refletir alterações sem reiniciar.
- Alterar wallpaper, rodar ecrã, mudar tema e reiniciar o dispositivo.
- Adicionar, configurar e remover widget de terceiros.
- Revogar permissões e confirmar comportamento degradado sem crash.
- Testar separadores/pastas com muitos itens.

### Não funcionais

- Testes de acessibilidade: TalkBack, contraste, alvos táteis e texto ampliado.
- Testes de consumo: bateria, CPU, RAM, frames perdidos e arranque.
- Testes em Android 10–16, dispositivos com diferentes resoluções e launchers de fabricantes.
- Verificar comportamento com economia de bateria e restrições de background.
- Garantir que dados de backup não incluem URIs inválidas ou tokens sensíveis.

## 13. Definição de pronto (Definition of Done)

Uma funcionalidade só está concluída quando: compila em release; possui testes relevantes; respeita permissões; trata falhas e estado vazio; não provoca regressões de desempenho; e está documentada no README.

## 14. Próximos passos de implementação

1. Criar repositório `VerticalTabsLauncher` e projeto Android Studio.
2. Implementar Activity HOME + navegação lateral em Compose.
3. Criar `AppsRepository` com observação de alterações de pacotes.
4. Implementar `TabEntity`/`TabItemEntity` e DataStore.
5. Adicionar seleção de wallpaper com Photo Picker e pipeline de imagem otimizado.
6. Criar ecrã de personalização com pré-visualização.
7. Medir desempenho do MVP antes de adicionar widgets e integrações.

---

**Nota legal e de produto:** o Vertical Tabs Launcher deve ter identidade visual própria e não depender de recursos gráficos protegidos de outros launchers. As permissões, políticas Google Play e restrições de visibilidade de aplicações devem ser verificadas antes da publicação.
