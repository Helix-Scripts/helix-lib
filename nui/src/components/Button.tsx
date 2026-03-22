import { forwardRef, type ButtonHTMLAttributes, type ReactNode } from 'react';
import { Loader2 } from 'lucide-react';
import styles from './Button.module.css';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  /** Visual style variant */
  variant?: ButtonVariant;
  /** Button size */
  size?: ButtonSize;
  /** Show a loading spinner and disable interaction */
  loading?: boolean;
  /** Optional icon to render before children */
  icon?: ReactNode;
}

/**
 * Primary UI button with multiple variants and sizes.
 * Supports loading and disabled states.
 */
export const Button = forwardRef<HTMLButtonElement, ButtonProps>(
  (
    {
      variant = 'primary',
      size = 'md',
      loading = false,
      disabled,
      icon,
      children,
      className,
      ...rest
    },
    ref,
  ) => {
    const cls = [styles.button, styles[variant], styles[size], className]
      .filter(Boolean)
      .join(' ');

    return (
      <button
        ref={ref}
        className={cls}
        disabled={disabled || loading}
        {...rest}
      >
        {loading ? (
          <span className={styles.spinner}>
            <Loader2 size={size === 'sm' ? 14 : size === 'lg' ? 20 : 16} />
          </span>
        ) : icon ? (
          icon
        ) : null}
        {children}
      </button>
    );
  },
);

Button.displayName = 'Button';
