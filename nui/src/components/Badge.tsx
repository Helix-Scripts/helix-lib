import { type ReactNode, type HTMLAttributes } from 'react';
import styles from './Badge.module.css';

export type BadgeVariant = 'success' | 'warning' | 'error' | 'info' | 'neutral';

export interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  /** Visual variant */
  variant?: BadgeVariant;
  /** Show a status dot before the label */
  dot?: boolean;
  children: ReactNode;
}

/**
 * Status indicator badge with colored variants and optional dot.
 */
export function Badge({
  variant = 'neutral',
  dot = false,
  children,
  className,
  ...rest
}: BadgeProps) {
  const cls = [styles.badge, styles[variant], className]
    .filter(Boolean)
    .join(' ');

  return (
    <span className={cls} {...rest}>
      {dot && <span className={styles.dot} />}
      {children}
    </span>
  );
}
