# frozen_string_literal: true

support_files = Dir[Rails.root.join("db/seeds/support/*.rb")].sort
support_files.each { |file| require file }

step_files = Dir[Rails.root.join("db/seeds/steps/*.rb")].sort
step_files.each { |file| load file }
