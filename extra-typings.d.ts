declare module 'react-draggable';
declare module 'reqwest';
declare module 'MD5';
declare module 'express-promise';

// Ripped RIGHT from lid.es6.d.ts because I want to use this on Chrome but
// I don't want to have to target ES6 and I know that this class exists there.
type PropertyKey = string | number | symbol;

interface ProxyHandler<T> {
    getPrototypeOf? (target: T): {} | null;
    setPrototypeOf? (target: T, v: any): boolean;
    isExtensible? (target: T): boolean;
    preventExtensions? (target: T): boolean;
    getOwnPropertyDescriptor? (target: T, p: PropertyKey): PropertyDescriptor;
    has? (target: T, p: PropertyKey): boolean;
    get? (target: T, p: PropertyKey, receiver: any): any;
    set? (target: T, p: PropertyKey, value: any, receiver: any): boolean;
    deleteProperty? (target: T, p: PropertyKey): boolean;
    defineProperty? (target: T, p: PropertyKey, attributes: PropertyDescriptor): boolean;
    enumerate? (target: T): PropertyKey[];
    ownKeys? (target: T): PropertyKey[];
    apply? (target: T, thisArg: any, argArray?: any): any;
    construct? (target: T, argArray: any, newTarget?: any): {};
}

interface ProxyConstructor {
    revocable<T>(target: T, handler: ProxyHandler<T>): { proxy: T; revoke: () => void; };
    new <T>(target: T, handler: ProxyHandler<T>): T
}
declare var Proxy: ProxyConstructor;

// Technically experimental, but exists on the browsers I care about.
interface Array<T> {
    includes(obj: any): boolean;
}
