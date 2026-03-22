import {
  createContext,
  useContext,
  useCallback,
  useState,
  useRef,
  type ReactNode,
} from 'react';
import { Toast, type ToastData, type ToastType } from './Toast';
import styles from './Toast.module.css';

interface ToastInput {
  type?: ToastType;
  title?: string;
  message: string;
  duration?: number;
}

interface ToastContextValue {
  /** Add a toast notification */
  addToast: (input: ToastInput) => void;
  /** Remove a toast by id */
  removeToast: (id: string) => void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

/**
 * Hook to access toast methods. Must be used inside a ToastProvider.
 */
export function useToast(): ToastContextValue {
  const ctx = useContext(ToastContext);
  if (!ctx) {
    throw new Error('useToast must be used within a ToastProvider');
  }
  return ctx;
}

export interface ToastProviderProps {
  children: ReactNode;
  /** Default auto-dismiss duration in ms */
  defaultDuration?: number;
}

let toastCounter = 0;

/**
 * Context provider that manages toast notifications.
 * Wrap your application with this to enable the useToast hook.
 */
export function ToastProvider({
  children,
  defaultDuration = 4000,
}: ToastProviderProps) {
  const [toasts, setToasts] = useState<ToastData[]>([]);
  const timers = useRef<Map<string, ReturnType<typeof setTimeout>>>(new Map());

  const removeToast = useCallback((id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
    const timer = timers.current.get(id);
    if (timer) {
      clearTimeout(timer);
      timers.current.delete(id);
    }
  }, []);

  const addToast = useCallback(
    (input: ToastInput) => {
      const id = `toast-${++toastCounter}`;
      const duration = input.duration ?? defaultDuration;
      const toast: ToastData = {
        id,
        type: input.type ?? 'info',
        title: input.title,
        message: input.message,
        duration,
      };

      setToasts((prev) => [...prev, toast]);

      if (duration > 0) {
        const timer = setTimeout(() => removeToast(id), duration);
        timers.current.set(id, timer);
      }
    },
    [defaultDuration, removeToast],
  );

  return (
    <ToastContext.Provider value={{ addToast, removeToast }}>
      {children}
      <div className={styles.container}>
        {toasts.map((t) => (
          <Toast key={t.id} toast={t} onDismiss={removeToast} />
        ))}
      </div>
    </ToastContext.Provider>
  );
}
