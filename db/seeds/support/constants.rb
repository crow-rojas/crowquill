# frozen_string_literal: true

module CrowquillSeeds
  DAY_OFFSETS = {
    "monday" => 0,
    "tuesday" => 1,
    "wednesday" => 2,
    "thursday" => 3,
    "friday" => 4,
    "saturday" => 5,
    "sunday" => 6
  }.freeze

  ROOMS = %w[S101 S102 S205 S301 S302 A-11 A-14 B-20 C-08 Lab-2].freeze

  TIME_SLOTS = [
    ["08:30", "10:00"],
    ["10:00", "11:30"],
    ["11:45", "13:15"],
    ["14:00", "15:30"],
    ["16:00", "17:30"],
    ["18:00", "19:30"]
  ].freeze

  JUSTIFICATION_NOTES = [
    "Medical note received.",
    "Clash with another course assessment.",
    "Academic permit approved by coordination.",
    "Institutional paperwork conflict."
  ].freeze

  CONTENT_FORMULAS = [
    "f(x) = \\frac{x^2 - 1}{x - 1}",
    "g(x) = \\sqrt{3x + 6}",
    "h(x) = e^{-x^2}",
    "p(x) = \\ln(x^2 + 1)",
    "q(x) = \\sin(2x) + \\cos(x)",
    "r(x) = \\frac{2x + 3}{x^2 + 1}"
  ].freeze

  GENERIC_TOPIC_POOL = [
    "Modeling",
    "Algebraic reasoning",
    "Graph interpretation",
    "Error analysis",
    "Numeric verification",
    "Mathematical argumentation"
  ].freeze

  AI_PROMPTS = [
    "I am not sure how to start this exercise. Can you guide me?",
    "I understand the theory, but I get lost when applying the chain rule.",
    "How can I quickly verify if my final result makes sense?",
    "Could you explain this as if I am seeing it for the first time?"
  ].freeze

  AI_RESPONSES = [
    "Sure. First identify givens and goal. Then choose one short strategy and validate your result.",
    "Good question. Rewrite the problem in a simpler form and apply the rule step by step.",
    "Lets split this into three parts: structure, operation, and quick check.",
    "Great that you asked. Use a 3-step workflow so you do not lose track of the procedure."
  ].freeze

  TUTOR_PROFILES = [
    ["tutor1@crowquill.dev", "Sebastian Vega"],
    ["tutor2@crowquill.dev", "Francisca Rojas"],
    ["tutor3@crowquill.dev", "Manuel Herrera"],
    ["tutor4@crowquill.dev", "Camila Paredes"],
    ["tutor5@crowquill.dev", "Valeria Diaz"],
    ["tutor6@crowquill.dev", "Nicolas Salinas"]
  ].freeze

  STUDENT_NAMES = [
    "Martin Gonzalez", "Valentina Silva", "Joaquin Perez", "Isidora Lopez",
    "Tomas Fernandez", "Catalina Diaz", "Matias Soto", "Antonia Martinez",
    "Benjamin Araya", "Sofia Castillo", "Lucas Morales", "Emilia Vargas",
    "Ignacia Torres", "Diego Contreras", "Vicente Riquelme", "Amanda Fuentes",
    "Pablo Mella", "Fernanda Reyes", "Renato Cifuentes", "Monica Cabrera",
    "Ariel Bustos", "Daniela Jara", "Bastian Bravo", "Florencia Pinto",
    "Alonso Pizarro", "Javiera Mendez", "Rocio Farias", "Franco Lagos"
  ].freeze

  COURSE_CATALOG = {
    "pimu-uc" => {
      archived: [
        {
          name: "Precalculo",
          description: "Algebra and functions foundations for university calculus."
        },
        {
          name: "Calculo I",
          description: "Limits, derivatives, and introductory applications."
        }
      ],
      active: [
        {
          name: "Precalculo",
          description: "Algebra, functions, and trigonometry reinforcement."
        },
        {
          name: "Calculo I",
          description: "Limits, derivatives, optimization, and approximation."
        },
        {
          name: "Algebra Lineal",
          description: "Vectors, matrices, and linear systems with applications."
        },
        {
          name: "Probabilidad",
          description: "Random variables, distributions, and basic inference."
        }
      ],
      draft: [
        {
          name: "Calculo II",
          description: "Integrals, series, and early multivariable ideas."
        },
        {
          name: "Ecuaciones Diferenciales",
          description: "Change modeling and numerical solving methods."
        }
      ]
    },
    "mate-usm" => {
      archived: [
        {
          name: "Algebra Universitaria",
          description: "Symbolic manipulation, polynomials, and equations."
        },
        {
          name: "Estadistica I",
          description: "Data description and probability distributions."
        }
      ],
      active: [
        {
          name: "Calculo II",
          description: "Advanced integration and approximation techniques."
        },
        {
          name: "Ecuaciones Diferenciales",
          description: "First and second order ODEs with applications."
        },
        {
          name: "Estadistica I",
          description: "Inference, estimation, and hypothesis testing."
        },
        {
          name: "Programacion Cientifica",
          description: "Computational methods for mathematical problem solving."
        }
      ],
      draft: [
        {
          name: "Optimizacion",
          description: "Linear and nonlinear optimization in applied cases."
        },
        {
          name: "Modelos Estocasticos",
          description: "Random processes and simulation for engineering."
        }
      ]
    }
  }.freeze

  CONVERSATION_PREFIXES = [
    "Exercise help",
    "Procedure question",
    "Quiz prep",
    "Exercise review",
    "Quick check"
  ].freeze
end
