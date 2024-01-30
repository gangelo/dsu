# frozen_string_literal: true

module StdxxxHelpers
  def strip_escapes(escaped_string)
    escaped_string.gsub(/\e\[[0-9;]*[a-zA-Z]/, '')
  end

  def stub_import_prompt(response:)
    allow($stdin).to receive(:getch).and_return(response)
  end
end
