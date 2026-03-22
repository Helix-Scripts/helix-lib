import {
  useState,
  useRef,
  useEffect,
  useCallback,
} from 'react';
import { ChevronDown } from 'lucide-react';
import styles from './Select.module.css';

export interface SelectOption {
  value: string;
  label: string;
}

export interface SelectProps {
  /** Options to choose from */
  options: SelectOption[];
  /** Currently selected value */
  value?: string;
  /** Called when the selection changes */
  onChange?: (value: string) => void;
  /** Label displayed above the select */
  label?: string;
  /** Placeholder text when nothing is selected */
  placeholder?: string;
  /** Enable search/filter in the dropdown */
  searchable?: boolean;
  /** Disable the select */
  disabled?: boolean;
}

/**
 * Custom dropdown select with optional search/filter capability.
 */
export function Select({
  options,
  value,
  onChange,
  label,
  placeholder = 'Select...',
  searchable = false,
  disabled = false,
}: SelectProps) {
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState('');
  const wrapperRef = useRef<HTMLDivElement>(null);
  const searchRef = useRef<HTMLInputElement>(null);

  const selected = options.find((o) => o.value === value);

  const filtered = search
    ? options.filter((o) =>
        o.label.toLowerCase().includes(search.toLowerCase()),
      )
    : options;

  const toggle = useCallback(() => {
    if (disabled) return;
    setOpen((prev) => {
      if (!prev) setSearch('');
      return !prev;
    });
  }, [disabled]);

  const select = useCallback(
    (val: string) => {
      onChange?.(val);
      setOpen(false);
    },
    [onChange],
  );

  /* Close on outside click */
  useEffect(() => {
    if (!open) return;
    const handler = (e: MouseEvent) => {
      if (
        wrapperRef.current &&
        !wrapperRef.current.contains(e.target as Node)
      ) {
        setOpen(false);
      }
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, [open]);

  /* Focus search input when opened */
  useEffect(() => {
    if (open && searchable) {
      searchRef.current?.focus();
    }
  }, [open, searchable]);

  return (
    <div className={styles.wrapper} ref={wrapperRef}>
      {label && <span className={styles.label}>{label}</span>}
      <button
        type="button"
        className={styles.trigger}
        onClick={toggle}
        disabled={disabled}
        aria-haspopup="listbox"
        aria-expanded={open}
      >
        {selected ? (
          selected.label
        ) : (
          <span className={styles.placeholder}>{placeholder}</span>
        )}
        <ChevronDown size={16} />
      </button>

      {open && (
        <div className={styles.dropdown} role="listbox">
          {searchable && (
            <input
              ref={searchRef}
              className={styles.search}
              placeholder="Search..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          )}
          <div className={styles.options}>
            {filtered.length === 0 ? (
              <div className={styles.empty}>No options found</div>
            ) : (
              filtered.map((opt) => (
                <div
                  key={opt.value}
                  role="option"
                  aria-selected={opt.value === value}
                  className={[
                    styles.option,
                    opt.value === value && styles.optionSelected,
                  ]
                    .filter(Boolean)
                    .join(' ')}
                  onClick={() => select(opt.value)}
                >
                  {opt.label}
                </div>
              ))
            )}
          </div>
        </div>
      )}
    </div>
  );
}
