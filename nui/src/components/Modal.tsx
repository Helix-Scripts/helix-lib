import { useEffect, useCallback, type ReactNode } from 'react';
import { X } from 'lucide-react';
import styles from './Modal.module.css';

export type ModalVariant = 'confirm' | 'form' | 'info';

export interface ModalProps {
  /** Whether the modal is visible */
  open: boolean;
  /** Called when the modal should close */
  onClose: () => void;
  /** Modal title */
  title?: string;
  /** Visual variant (for semantic purposes) */
  variant?: ModalVariant;
  /** Close when pressing Escape */
  closeOnEscape?: boolean;
  /** Close when clicking the backdrop */
  closeOnBackdrop?: boolean;
  /** Content rendered in the body */
  children?: ReactNode;
  /** Content rendered in the footer (typically action buttons) */
  footer?: ReactNode;
}

/**
 * Overlay modal dialog with support for Escape key and backdrop click dismissal.
 */
export function Modal({
  open,
  onClose,
  title,
  variant = 'info',
  closeOnEscape = true,
  closeOnBackdrop = true,
  children,
  footer,
}: ModalProps) {
  const handleKeyDown = useCallback(
    (e: KeyboardEvent) => {
      if (closeOnEscape && e.key === 'Escape') {
        onClose();
      }
    },
    [closeOnEscape, onClose],
  );

  useEffect(() => {
    if (!open) return;
    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [open, handleKeyDown]);

  if (!open) return null;

  return (
    <div
      className={styles.backdrop}
      onClick={closeOnBackdrop ? onClose : undefined}
      role="dialog"
      aria-modal="true"
      data-variant={variant}
    >
      <div className={styles.modal} onClick={(e) => e.stopPropagation()}>
        {title && (
          <div className={styles.header}>
            <span className={styles.title}>{title}</span>
            <button
              className={styles.closeBtn}
              onClick={onClose}
              aria-label="Close modal"
            >
              <X size={16} />
            </button>
          </div>
        )}
        <div className={styles.body}>{children}</div>
        {footer && <div className={styles.footer}>{footer}</div>}
      </div>
    </div>
  );
}
