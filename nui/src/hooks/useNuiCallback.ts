import { useCallback, useState } from 'react';
import { fetchNui } from '../utils/nui';

interface UseNuiCallbackReturn<TResponse> {
  data: TResponse | null;
  loading: boolean;
  error: string | null;
  execute: (data?: unknown) => Promise<TResponse>;
}

/**
 * Sends data to the Lua client via NUI callback and awaits a response.
 *
 * @param callbackName - The NUI callback name registered in Lua.
 */
export function useNuiCallback<TResponse = unknown>(
  callbackName: string,
): UseNuiCallbackReturn<TResponse> {
  const [data, setData] = useState<TResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const execute = useCallback(
    async (requestData?: unknown): Promise<TResponse> => {
      setLoading(true);
      setError(null);

      try {
        const result = await fetchNui<TResponse>(callbackName, requestData);
        setData(result);
        return result;
      } catch (err) {
        const message = err instanceof Error ? err.message : 'Unknown error';
        setError(message);
        throw err;
      } finally {
        setLoading(false);
      }
    },
    [callbackName],
  );

  return { data, loading, error, execute };
}
