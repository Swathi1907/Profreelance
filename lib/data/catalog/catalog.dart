/// Fixed option lists used by the forms. Domains are grouped so the picker
/// stays scannable even with 70+ entries.
const kDomainCatalog = <String, List<String>>{
  'Software & IT': [
    'Mobile App Development',
    'Web Development',
    'Backend / API Development',
    'Full-Stack Development',
    'Desktop Software',
    'Game Development',
    'Embedded Systems / IoT',
    'Cloud & DevOps',
    'Cybersecurity',
    'QA & Test Automation',
    'Blockchain & Web3',
    'AR / VR / XR',
    'ERP / CRM Customisation',
    'WordPress / CMS',
    'E-commerce Platforms',
    'Database Design & Administration',
    'Chatbots & Conversational AI',
  ],
  'Data & AI': [
    'Machine Learning',
    'Deep Learning / Computer Vision',
    'NLP / LLM Applications',
    'Generative AI',
    'Data Science & Analytics',
    'Data Engineering',
    'Business Intelligence & Dashboards',
    'MLOps',
  ],
  'Design & Creative': [
    'UI/UX Design',
    'Graphic Design',
    'Branding & Identity',
    'Illustration',
    'Motion Graphics & Animation',
    'Video Editing',
    '3D Modelling & Rendering',
    'Photography',
    'Audio & Music Production',
    'Voice-over',
    'Presentation Design',
  ],
  'Marketing & Content': [
    'Digital Marketing',
    'SEO',
    'Social Media Management',
    'Content Writing',
    'Copywriting',
    'Technical Writing',
    'Email Marketing',
    'Community Management',
    'Translation & Localisation',
    'Transcription',
  ],
  'Business & Professional': [
    'Business Consulting',
    'Product Management',
    'Project Management',
    'Financial Modelling',
    'Accounting & Bookkeeping',
    'Legal Drafting',
    'HR & Recruitment',
    'Market Research',
    'Virtual Assistance',
    'Data Entry',
  ],
  'Engineering & Education': [
    'CAD / Mechanical Design',
    'Electronics & PCB Design',
    'Robotics',
    'Civil & Architecture',
    'Research & Academic Writing',
    'Tutoring & Coaching',
    'Instructional Design',
  ],
};

const kSubDomainHints = <String, List<String>>{
  'Mobile App Development': ['E-commerce', 'Food-tech', 'Health', 'Messaging', 'Fintech', 'Education'],
  'Web Development': ['Portfolio', 'Dashboard', 'Marketing site', 'SaaS', 'E-commerce', 'Booking'],
  'UI/UX Design': ['Design system', 'Mobile screens', 'Landing page', 'Prototype', 'Research'],
  'Machine Learning': ['Forecasting', 'Classification', 'Recommendation', 'Anomaly detection'],
  'NLP / LLM Applications': ['Chatbot', 'Summarisation', 'Search', 'Classification'],
};

const kTechComponents = [
  'Authentication',
  'Payments',
  'Database',
  'Third-party APIs',
  'Machine Learning',
  'Real-time',
  'Cloud Deployment',
  'Admin Dashboard',
  'Analytics',
  'Push Notifications',
  'File Storage',
  'Search',
  'Offline Mode',
  'Multi-language',
];

const kExternalDeps = ['Client Approvals', 'External Services', 'Hardware', 'Client Content', 'Third-party Licences', 'App Store Review'];

const kPaymentStructures = [
  'Milestone-based',
  '50% advance, 50% on delivery',
  'Fixed price',
  'Hourly (time and materials)',
  'Monthly retainer',
];

const kIpOptions = [
  'Client, on full payment',
  'Freelancer retains, client gets a licence',
  'Joint ownership',
  'Client, immediately',
];

const kCurrencies = ['INR', 'USD', 'EUR', 'GBP', 'AED', 'SGD'];
const kDurationUnits = ['Days', 'Weeks', 'Months'];

const kComplexity = <String, int>{'Basic': 2, 'Intermediate': 3, 'Advanced': 5};

String complexityLabel(int c) => c <= 2 ? 'Basic' : (c <= 3 ? 'Intermediate' : 'Advanced');

int durationToDays(int value, String unit) => switch (unit) {
      'Days' => value,
      'Weeks' => value * 7,
      _ => value * 30,
    };
