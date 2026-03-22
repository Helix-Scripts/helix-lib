import { useState, type ReactNode } from 'react';
import styles from './Tabs.module.css';

export interface TabItem {
  /** Unique key for the tab */
  key: string;
  /** Tab label */
  label: string;
  /** Tab panel content */
  content: ReactNode;
}

export interface TabsProps {
  /** Tab definitions */
  items: TabItem[];
  /** Controlled active tab key */
  activeKey?: string;
  /** Called when the active tab changes */
  onChange?: (key: string) => void;
}

/**
 * Tab navigation component with content panels.
 * Can be used in controlled or uncontrolled mode.
 */
export function Tabs({ items, activeKey, onChange }: TabsProps) {
  const [internalKey, setInternalKey] = useState(items[0]?.key ?? '');
  const current = activeKey ?? internalKey;

  const handleChange = (key: string) => {
    if (onChange) {
      onChange(key);
    } else {
      setInternalKey(key);
    }
  };

  const activeItem = items.find((item) => item.key === current);

  return (
    <div className={styles.wrapper}>
      <div className={styles.tabList} role="tablist">
        {items.map((item) => (
          <button
            key={item.key}
            role="tab"
            aria-selected={item.key === current}
            className={[styles.tab, item.key === current && styles.tabActive]
              .filter(Boolean)
              .join(' ')}
            onClick={() => handleChange(item.key)}
          >
            {item.label}
          </button>
        ))}
      </div>
      <div className={styles.panel} role="tabpanel">
        {activeItem?.content}
      </div>
    </div>
  );
}
