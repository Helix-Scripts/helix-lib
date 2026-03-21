import { useEffect, useRef } from 'react';

/**
 * Listens for NUI messages from the Lua client.
 * Filters incoming window messages by the `action` field.
 *
 * @param action - The action name to listen for.
 * @param handler - Callback invoked with the message data payload.
 */
export function useNuiEvent<T = unknown>(action: string, handler: (data: T) => void): void {
  const savedHandler = useRef(handler);

  useEffect(() => {
    savedHandler.current = handler;
  }, [handler]);

  useEffect(() => {
    function eventListener(event: MessageEvent) {
      const { action: eventAction, data } = event.data;
      if (eventAction === action) {
        savedHandler.current(data as T);
      }
    }

    window.addEventListener('message', eventListener);
    return () => window.removeEventListener('message', eventListener);
  }, [action]);
}
