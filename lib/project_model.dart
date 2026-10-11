class Project {
  final String id;
  final String title;
  final String description;
  final String longDescription;
  final String imageUrl;
  final String webUrl;
  final String apkUrl;
  final String githubUrl;
  final String category;
  final List<String> techStack;
  final List<String> screenshots; // local asset paths

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.longDescription,
    required this.imageUrl,
    required this.webUrl,
    required this.apkUrl,
    required this.githubUrl,
    required this.category,
    required this.techStack,
    required this.screenshots,
  });
}

final List<Project> myProjects = [
  Project(
    id: 'wizpr',
    title: 'Wizpr',
    category: 'Chat Application',
    description:
        'A Flutter & Firebase-based chatting app with real-time messaging and secure authentication.',
    longDescription:
        'Wizpr is a full-featured real-time messaging application built with Flutter and Firebase. '
        'It supports secure email/Google authentication, real-time chat with Firestore, '
        'user profiles, online presence indicators, and a clean, intuitive UI. '
        'The app features end-to-end encrypted messaging, push notifications, '
        'image sharing, and a beautiful dark-themed interface designed for modern users.',
    imageUrl: 'assets/img/wizpr/5.jpg',
    webUrl: 'https://wizpr-chat.web.app/',
    apkUrl:
        'https://drive.google.com/file/d/1ZfmtFh0dzqeIC0gaJQ2g8EFqyU7P2Bht/view?usp=sharing',
    githubUrl: 'https://github.com/ansh-lowanshi/cahtApp-wizpr',
    techStack: ['Flutter', 'Firebase', 'Firestore', 'Auth', 'Dart'],
    screenshots: [
      'assets/img/wizpr/1.jpg',
      'assets/img/wizpr/2.jpg',
      'assets/img/wizpr/3.jpg',
      'assets/img/wizpr/4.jpg',
      'assets/img/wizpr/5.jpg',
      'assets/img/wizpr/6.jpg',
      'assets/img/wizpr/7.jpg',
      'assets/img/wizpr/8.jpg',
    ],
  ),
  Project(
    id: 'wizplayer',
    title: 'WizPlayer',
    category: 'Music Streaming',
    description:
        'A cross-platform music streaming app with a sleek UI and offline playback capabilities.',
    longDescription:
        'WizPlayer is a feature-rich music player built with Flutter. '
        'It offers online streaming via the JioSaavn API, offline playback, '
        'a beautiful animated player UI, playlist management, album art display, '
        'and seamless audio controls. The app uses just_audio and audio_service '
        'for background playback and lock-screen controls.',
    imageUrl:
        'assets/img/WizPlayer/Screenshot_2026-08-24-22-22-25-303_com.example.wiz_player.jpg',
    webUrl: 'https://wiz_player.web.app/',
    apkUrl:
        'https://drive.google.com/file/d/1om4uwDpuKfVVZhN4yKq7uEtk68M-Oh8p/view?usp=sharing',
    githubUrl: 'https://github.com/ansh-lowanshi/wiz_player',
    techStack: ['Flutter', 'Dart', 'JioSaavn API', 'just_audio', 'Hive'],
    screenshots: [
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-22-25-303_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-22-35-476_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-22-44-793_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-22-51-640_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-23-01-525_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-23-06-181_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-23-16-017_com.example.wiz_player.jpg',
      'assets/img/WizPlayer/Screenshot_2026-08-24-22-23-51-220_com.example.wiz_player.jpg',
    ],
  ),
  Project(
    id: 'aichatbot',
    title: 'AI Chat Bot',
    category: 'AI / ML',
    description:
        'An intelligent assistant powered by Gemini AI, capable of handling complex queries and conversations.',
    longDescription:
        'AI Chat Bot is a Flutter application that integrates Google\'s Gemini AI to provide '
        'intelligent conversational assistance. Users can ask complex questions, get code help, '
        'creative writing assistance, and more. Features include conversation history, '
        'markdown rendering for responses, code syntax highlighting, and a beautiful '
        'chat interface that feels natural and responsive.',
    imageUrl: 'assets/img/aichatbot/4.jpg',
    webUrl: 'https://ai-chatbot-ansh.web.app/',
    apkUrl:
        'https://drive.google.com/drive/folders/1YRgyHFKOI1T9IvNoe3igkMc8j8z4fy1k?usp=sharing',
    githubUrl: 'https://github.com/ansh-lowanshi/Ai-ChatBot',
    techStack: ['Flutter', 'Gemini AI', 'Dart', 'Google AI SDK'],
    screenshots: [
      'assets/img/aichatbot/1.jpg',
      'assets/img/aichatbot/2.jpg',
      'assets/img/aichatbot/3.jpg',
      'assets/img/aichatbot/4.jpg',
      'assets/img/aichatbot/5.jpg',
    ],
  ),
  Project(
    id: 'ffms',
    title: 'FFMS',
    category: 'Enterprise App',
    description:
        'Field Force Management System designed for industries to track and manage their workforce efficiently.',
    longDescription:
        'FFMS (Field Force Management System) is an enterprise-grade Flutter application '
        'developed during my internship at Sentient Digital Pvt. Ltd. '
        'It enables real-time location tracking of field workers, task assignment, '
        'attendance management, route optimization, and reporting dashboards. '
        'Built with Riverpod for state management and REST APIs for backend integration, '
        'it handles complex business logic while maintaining a clean, intuitive UI.',
    imageUrl: 'assets/img/ffms/1.jpg',
    webUrl: 'https://ffms-system.web.app/',
    apkUrl:
        'https://drive.google.com/drive/folders/1YRgyHFKOI1T9IvNoe3igkMc8j8z4fy1k?usp=sharing',
    githubUrl: '',
    techStack: ['Flutter', 'Riverpod', 'REST APIs', 'Maps', 'Dart'],
    screenshots: [
      'assets/img/ffms/1.jpg',
      'assets/img/ffms/2.jpg',
      'assets/img/ffms/3.jpg',
      'assets/img/ffms/4.jpg',
      'assets/img/ffms/5.jpg',
      'assets/img/ffms/6.jpg',
      'assets/img/ffms/7.jpg',
    ],
  ),
  Project(
    id: 'moviebasket',
    title: 'Movie Basket',
    category: 'Entertainment',
    description:
        'A movie discovery app where users can search for movies, view details, and manage their watchlist.',
    longDescription:
        'Movie Basket is a Flutter app powered by the TMDB API that lets users discover '
        'movies and TV shows. Features include search with filters, trending/popular sections, '
        'detailed movie pages with cast info, user reviews, trailer playback, '
        'and a personal watchlist saved locally. The app uses GetX for state management '
        'and implements a clean architecture pattern.',
    imageUrl: 'assets/img/movie_search/1.jpg',
    webUrl: 'https://movie-basket.web.app/',
    apkUrl:
        'https://drive.google.com/file/d/1zzbjLkzdSadUSJS9h6Ia7RoVh0RGufII/view?usp=sharing',
    githubUrl: 'https://github.com/ansh-lowanshi/MovieBasket',
    techStack: ['Flutter', 'TMDB API', 'GetX', 'Dart', 'REST API'],
    screenshots: [
      'assets/img/movie_search/1.jpg',
      'assets/img/movie_search/2.jpg',
      'assets/img/movie_search/3.jpg',
    ],
  ),
  Project(
    id: 'ecommerce',
    title: 'Mini E-commerce',
    category: 'E-commerce',
    description:
        'A compact shopping platform with product listings, cart functionality, and secure checkout.',
    longDescription:
        'Mini E-commerce is a Flutter shopping app that demonstrates a complete e-commerce flow. '
        'It features product browsing with category filters, detailed product pages, '
        'add to cart functionality, quantity management, order summary, '
        'and a simulated checkout flow. The UI follows material design principles '
        'with a clean, modern look that prioritizes usability and conversion.',
    imageUrl: 'assets/img/mini-e-commerce/1.jpg',
    webUrl: 'https://mini-ecommerce-ansh.web.app/',
    apkUrl:
        'https://drive.google.com/file/d/1bshH3fWS3uoqCg5RiOuHwreK-Qv8gl0h/view?usp=sharing',
    githubUrl: 'https://github.com/ansh-lowanshi/mini_shopping_app',
    techStack: ['Flutter', 'Provider', 'Dart', 'REST API'],
    screenshots: [
      'assets/img/mini-e-commerce/1.jpg',
      'assets/img/mini-e-commerce/2.jpg',
      'assets/img/mini-e-commerce/3.jpg',
    ],
  ),
];
