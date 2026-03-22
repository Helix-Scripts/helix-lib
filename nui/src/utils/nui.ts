/**
 * Returns true when running outside FiveM (e.g. in a regular browser for dev).
 */
export function isEnvBrowser(): boolean {
  return !(window as unknown as Record<string, unknown>).invokeNative;
}

/**
 * Get the parent resource name. Falls back to 'helix_lib' outside FiveM.
 */
function getResourceName(): string {
  if (isEnvBrowser()) return 'helix_lib';
  const win = window as unknown as Record<string, unknown>;
  return typeof win.GetParentResourceName === 'function'
    ? (win.GetParentResourceName as () => string)()
    : 'helix_lib';
}

/**
 * Send a NUI callback to the Lua client and return the response.
 *
 * @param callbackName - Name of the NUI callback registered in Lua.
 * @param data - Optional data payload to send.
 * @returns The response from the Lua callback handler.
 */
export async function fetchNui<T = unknown>(callbackName: string, data?: unknown): Promise<T> {
  if (isEnvBrowser()) {
    // In browser dev mode, return an empty resolved promise for easy stubbing.
    return Promise.resolve({} as T);
  }

  const resourceName = getResourceName();
  const url = `https://cfx-nui-${resourceName}/${callbackName}`;

  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data ?? {}),
  });

  return response.json() as Promise<T>;
}
