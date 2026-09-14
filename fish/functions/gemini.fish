function gemini --wraps='npx @google/gemini-cli' --wraps='npx @google/gemini-cli -m gemini-3-flash-preview' --description 'alias gemini=npx @google/gemini-cli -m gemini-3-flash-preview'
    npx @google/gemini-cli -m gemini-3-flash-preview $argv
end
