// The session endpoint is served by the Rails API in a separate repository.
// This client is a thin fetch wrapper; the response shape is owned upstream.

export async function fetchSession() {
  const res = await fetch(`${process.env.API_URL}/api/v1/session`, {
    headers: { Accept: 'application/json' },
    cache: 'no-store',
  });

  if (!res.ok) {
    throw new Error(`session request failed: ${res.status}`);
  }

  return res.json();
}
