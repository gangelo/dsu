#!/usr/bin/env ruby

# frozen_string_literal: true

require 'bundler/setup'
require 'highline'
require 'dsu'

def run_migrations?
  puts '***********************************************'
  puts '***        Migrations are pending!          ***'
  puts '***  This is a pre-release version of dsu.  ***'
  puts '***    It is highly recommended you exit    ***'
  puts '***           this installation!            ***'
  puts '***********************************************'
  prompt = 'What do you want to do?' \
           "\n  c = Continue (install and run migrations)." \
           "\n  x = Exit (recommended)." \
           "\n> "
  input = HighLine.new.ask(prompt, String) do |question|
    question.default = 'x'
    question.readline = true
    question.in = %w[x c]
  end
  input == 'c'
end

def run_migrations!
  return 1 unless run_migrations?

  puts 'Running migrations...'
  Dsu::Migration::Service.run_migrations!
  0
rescue StandardError => e
  puts "Error running migrations: #{e.message}"
  1
end

if Dsu::Migration::Service.run_migrations?
  exit run_migrations!
else
  exit 0
end
