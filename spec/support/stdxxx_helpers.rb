# frozen_string_literal: true

module StdxxxHelpers
  def strip_escapes(escaped_string)
    escaped_string.gsub(/\e\[[0-9;]*[a-zA-Z]/, '')
  end

  def stub_import_prompt(response:)
    allow($stdin).to receive(:getch) do
      response.is_a?(Array) ? response.shift : response
    end
  end

  def capture_stdout_and_strip_escapes(&block)
    strip_escapes(Dsu::Services::StdoutRedirectorService.call(&block).chomp)
  end
end
