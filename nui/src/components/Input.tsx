import { forwardRef, type InputHTMLAttributes } from 'react';
import { Search } from 'lucide-react';
import styles from './Input.module.css';

export interface InputProps
  extends Omit<InputHTMLAttributes<HTMLInputElement>, 'type'> {
  /** Input type */
  type?: 'text' | 'number' | 'search';
  /** Label displayed above the input */
  label?: string;
  /** Validation error message */
  error?: string;
}

/**
 * Text input component with optional label, search icon, and validation error display.
 */
export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ type = 'text', label, error, className, id, ...rest }, ref) => {
    const inputId = id ?? (label ? label.toLowerCase().replace(/\s+/g, '-') : undefined);
    const wrapperCls = [styles.wrapper, error && styles.hasError, className]
      .filter(Boolean)
      .join(' ');

    return (
      <div className={wrapperCls}>
        {label && (
          <label htmlFor={inputId} className={styles.label}>
            {label}
          </label>
        )}
        <div className={styles.inputWrap}>
          {type === 'search' && (
            <Search size={14} className={styles.searchIcon} />
          )}
          <input
            ref={ref}
            id={inputId}
            type={type === 'search' ? 'text' : type}
            className={[styles.input, type === 'search' && styles.searchInput]
              .filter(Boolean)
              .join(' ')}
            aria-invalid={!!error}
            {...rest}
          />
        </div>
        {error && <span className={styles.error}>{error}</span>}
      </div>
    );
  },
);

Input.displayName = 'Input';
