import { useEffect, useRef } from 'react';

/**
 * Listens for a specific keyboard key press and invokes the handler.
 *
 * @param key - The key to listen for (e.g. 'Escape', 'Enter').
 * @param handler - Callback invoked when the key is pressed.
 */
export function useKeyPress(key: string, handler: (event: KeyboardEvent) => void): void {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === key) {
        savedHandler.current(event);
      }
    }

    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [key]);
}
