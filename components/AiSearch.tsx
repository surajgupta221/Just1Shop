
import React, { useState } from 'react';
import { getGroceryInfo } from '../services/geminiService';
import type { GroundingChunk } from '../types';
import { SparklesIcon } from './icons';

const AiSearch: React.FC = () => {
  const [query, setQuery] = useState('');
  const [result, setResult] = useState<{ text: string; sources: GroundingChunk[] } | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!query.trim()) return;

    setIsLoading(true);
    setError(null);
    setResult(null);

    try {
      const response = await getGroceryInfo(query);
      setResult(response);
    } catch (err) {
      setError('Failed to get a response. Please check your connection or API key.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="bg-gradient-to-r from-green-50 to-cyan-50 py-12 sm:py-16">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center mb-8">
          <SparklesIcon className="w-10 h-10 mx-auto text-green-500" />
          <h2 className="text-3xl font-extrabold text-gray-900 sm:text-4xl mt-2">Your Grocery Guru</h2>
          <p className="mt-4 text-lg text-gray-600">Ask anything! e.g., "health benefits of salmon" or "how to store avocados?"</p>
        </div>
        <form onSubmit={handleSearch} className="flex flex-col sm:flex-row gap-2">
          <input
            type="text"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Ask a question..."
            className="flex-grow p-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-green-500 focus:border-transparent transition"
            disabled={isLoading}
          />
          <button
            type="submit"
            disabled={isLoading}
            className="bg-green-600 text-white font-bold py-3 px-6 rounded-lg shadow-md hover:bg-green-700 disabled:bg-gray-400 disabled:cursor-not-allowed transition-all transform hover:scale-105 flex items-center justify-center"
          >
            {isLoading ? (
              <>
                <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                  <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Asking...
              </>
            ) : 'Ask'}
          </button>
        </form>

        {error && <p className="mt-4 text-center text-red-600">{error}</p>}

        {result && (
          <div className="mt-8 bg-white p-6 rounded-lg shadow-lg animate-fade-in">
            <p className="text-gray-800 whitespace-pre-wrap">{result.text}</p>
            {result.sources.length > 0 && (
              <div className="mt-6">
                <h4 className="text-sm font-semibold text-gray-600">Sources:</h4>
                <ul className="list-disc list-inside mt-2 space-y-1">
                  {result.sources.map((source, index) => (
                    <li key={index} className="text-sm text-blue-600 hover:text-blue-800 break-all">
                      <a href={source.web.uri} target="_blank" rel="noopener noreferrer">{source.web.title || source.web.uri}</a>
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default AiSearch;
