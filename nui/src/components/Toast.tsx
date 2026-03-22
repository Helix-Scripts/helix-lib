import { CheckCircle, XCircle, AlertTriangle, Info, X } from 'lucide-react';
import styles from './Toast.module.css';

export type ToastType = 'success' | 'error' | 'warning' | 'info';

export interface ToastData {
  id: string;
  type: ToastType;
  title?: string;
  message: string;
  /** Duration in ms before auto-dismiss (0 = manual only) */
  duration?: number;
}

const icons: Record<ToastType, typeof CheckCircle> = {
  success: CheckCircle,
  error: XCircle,
  warning: AlertTriangle,
  info: Info,
};

export interface ToastProps {
  toast: ToastData;
  onDismiss: (id: string) => void;
}

/**
 * Individual toast notification element.
 */
export function Toast({ toast, onDismiss }: ToastProps) {
  const Icon = icons[toast.type];

  return (
    <div className={[styles.toast, styles[toast.type]].join(' ')} role="alert">
      <span className={styles.icon}>
        <Icon size={16} />
      </span>
      <div className={styles.content}>
        {toast.title && <div className={styles.title}>{toast.title}</div>}
        <div className={styles.message}>{toast.message}</div>
      </div>
      <button
        className={styles.dismiss}
        onClick={() => onDismiss(toast.id)}
        aria-label="Dismiss"
      >
        <X size={14} />
      </button>
    </div>
  );
}
