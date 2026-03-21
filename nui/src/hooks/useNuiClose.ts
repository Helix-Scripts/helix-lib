import { useCallback } from 'react';
import { fetchNui } from '../utils/nui';

/**
 * Returns a function that closes the NUI frame by sending
 * a "close" callback to the Lua client.
 */
export function useNuiClose(): () => void {
  return useCallback(() => {
    fetchNui('close');
  }, []);
}
